# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "spanner_helper"
require "concurrent"

describe "Spanner Client", :batch_update, :spanner do
  let(:db) { spanner_client }
  let(:insert_dml) { "INSERT INTO accounts (account_id, username, active, reputation) VALUES (@account_id, @username, @active, @reputation)" }
  let(:update_dml) { "UPDATE accounts SET username = @username, active = @active WHERE account_id = @account_id" }
  let(:update_dml_syntax_error) { "UPDDDD accounts" }
  let(:delete_dml) { "DELETE FROM accounts WHERE account_id = @account_id" }
  let(:insert_params) { { account_id: 4, username: "inserted", active: true, reputation: 88.8 } }
  let(:update_params) { { account_id: 4, username: "updated", active: false } }
  let(:delete_params) { { account_id: 4 } }

  before do
    db.commit do |c|
      c.delete "accounts"
      c.insert "accounts", default_account_rows
    end
  end

  after do
    db.delete "accounts"
  end

  it "executes multiple DML statements in a batch" do
    prior_results = db.execute_sql "SELECT * FROM accounts"
    prior_results.rows.count.must_equal 3

    timestamp = db.transaction do |tx|
      tx.transaction_id.wont_be :nil?

      row_counts = tx.batch_update do |b|
        b.batch_update insert_dml, params: insert_params
        b.batch_update update_dml, params: update_params
        b.batch_update delete_dml, params: delete_params
      end

      row_counts.must_be_kind_of Array
      row_counts.count.must_equal 3
      row_counts[0].must_equal 1
      row_counts[1].must_equal 1
      row_counts[2].must_equal 1

      update_results = tx.execute_sql \
        "SELECT username FROM accounts WHERE account_id = @account_id",
        params: { account_id: 4 }
      update_results.rows.count.must_equal 0
    end
    timestamp.must_be_kind_of Time
  end

  it "raises InvalidArgumentError when no DML statements are executed in a batch" do
      prior_results = db.execute_sql "SELECT * FROM accounts"
      prior_results.rows.count.must_equal 3

      timestamp = db.transaction do |tx|
        tx.transaction_id.wont_be :nil?

        err = expect do
          tx.batch_update do |b| end
        end.must_raise Google::Cloud::InvalidArgumentError
        err.message.must_equal "3:No statements in batch DML request."
      end
    timestamp.must_be_kind_of Time
  end

  it "executes multiple DML statements in a batch with syntax error" do
    prior_results = db.execute_sql "SELECT * FROM accounts"
    prior_results.rows.count.must_equal 3

    timestamp = db.transaction do |tx|
      tx.transaction_id.wont_be :nil?
      begin
        tx.batch_update do |b|
          b.batch_update insert_dml, params: insert_params
          b.batch_update update_dml_syntax_error, params: update_params
          b.batch_update delete_dml, params: delete_params
        end
      rescue Google::Cloud::Spanner::BatchUpdateError => batch_update_error
        batch_update_error.cause.must_be_kind_of Google::Cloud::InvalidArgumentError
        batch_update_error.cause.message.must_equal "Statement 1: 'UPDDDD accounts' is not valid DML."

        row_counts = batch_update_error.row_counts
        row_counts.must_be_kind_of Array
        row_counts.count.must_equal 1
        row_counts[0].must_equal 1
      end
      update_results = tx.execute_sql \
        "SELECT username FROM accounts WHERE account_id = @account_id",
        params: { account_id: 4 }
      update_results.rows.count.must_equal 1 # DELETE statement did not execute.
    end
    timestamp.must_be_kind_of Time
  end

  it "runs execute_update and batch_update in the same transaction" do
    prior_results = db.execute_sql "SELECT * FROM accounts"
    prior_results.rows.count.must_equal 3

    timestamp = db.transaction do |tx|
      tx.transaction_id.wont_be :nil?

      row_counts = tx.batch_update do |b|
        b.batch_update insert_dml, params: insert_params
        b.batch_update update_dml, params: update_params
      end

      row_counts.must_be_kind_of Array
      row_counts.count.must_equal 2
      row_counts[0].must_equal 1
      row_counts[1].must_equal 1

      delete_row_count = tx.execute_update delete_dml, params: delete_params

      delete_row_count.must_equal 1

      update_results = tx.execute_sql \
        "SELECT username FROM accounts WHERE account_id = @account_id",
        params: { account_id: 4 }
      update_results.rows.count.must_equal 0
    end
    timestamp.must_be_kind_of Time
  end
end
