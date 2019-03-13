# Copyright 2019 Google LLC
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

require "helper"

describe Google::Cloud::Spanner::Transaction, :batch_update, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:transaction_id) { "tx789" }
  let(:transaction_grpc) { Google::Spanner::V1::Transaction.new id: transaction_id }
  let(:transaction) { Google::Cloud::Spanner::Transaction.from_grpc transaction_grpc, session }
  let(:tx_selector) { Google::Spanner::V1::TransactionSelector.new id: transaction_id }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let(:timestamp) { Time.parse "2017-01-01 20:04:05.06 -0700" }
  let(:date) { Date.parse "2017-01-02" }
  let(:file) { StringIO.new "contents" }

  it "can execute a single DML query" do
    mock = Minitest::Mock.new
    mock.expect :execute_batch_dml, batch_response_grpc, [session_grpc.name, tx_selector, [statement_grpc("UPDATE users SET active = true")], 1, options: default_options]
    session.service.mocked_service = mock

    row_counts = transaction.batch_update do |b|
      b.batch_update "UPDATE users SET active = true"
    end

    mock.verify

    row_counts.count.must_equal 1
    row_counts.first.must_equal 1
  end

  it "can execute a DML query with multiple statements and param types" do
    mock = Minitest::Mock.new
    statements = []
    statements << statement_grpc("UPDATE users SET active = @active", params: Google::Protobuf::Struct.new(fields: { "active" => Google::Protobuf::Value.new(bool_value: true) }), param_types: { "active" => Google::Spanner::V1::Type.new(code: :BOOL) })
    statements << statement_grpc("UPDATE users SET age = @age", params: Google::Protobuf::Struct.new(fields: { "age" => Google::Protobuf::Value.new(string_value: "29") }), param_types: { "age" => Google::Spanner::V1::Type.new(code: :INT64) })
    statements << statement_grpc("UPDATE users SET score = @score", params: Google::Protobuf::Struct.new(fields: { "score" => Google::Protobuf::Value.new(number_value: 0.9) }), param_types: { "score" => Google::Spanner::V1::Type.new(code: :FLOAT64) })
    statements << statement_grpc("UPDATE users SET updated_at = @updated_at", params: Google::Protobuf::Struct.new(fields: { "updated_at" => Google::Protobuf::Value.new(string_value: "2017-01-02T03:04:05.060000000Z") }), param_types: { "updated_at" => Google::Spanner::V1::Type.new(code: :TIMESTAMP) })
    statements << statement_grpc("UPDATE users SET birthday = @birthday", params: Google::Protobuf::Struct.new(fields: { "birthday" => Google::Protobuf::Value.new(string_value: "2017-01-02") }), param_types: { "birthday" => Google::Spanner::V1::Type.new(code: :DATE) })
    statements << statement_grpc("UPDATE users SET name = @name", params: Google::Protobuf::Struct.new(fields: { "name" => Google::Protobuf::Value.new(string_value: "Charlie") }), param_types: { "name" => Google::Spanner::V1::Type.new(code: :STRING) })
    statements << statement_grpc("UPDATE users SET avatar = @avatar", params: Google::Protobuf::Struct.new(fields: { "avatar" => Google::Protobuf::Value.new(string_value: Base64.strict_encode64("contents")) }), param_types: { "avatar" => Google::Spanner::V1::Type.new(code: :BYTES) })
    statements << statement_grpc("UPDATE users SET project_ids = @list", params: Google::Protobuf::Struct.new(fields: { "list" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "1"), Google::Protobuf::Value.new(string_value: "2"), Google::Protobuf::Value.new(string_value: "3")])) }), param_types: { "list" => Google::Spanner::V1::Type.new(code: :ARRAY, array_element_type: Google::Spanner::V1::Type.new(code: :INT64)) })
    statements << statement_grpc("UPDATE users SET settings = @dict", params: Google::Protobuf::Struct.new(fields: { "dict" => Google::Protobuf::Value.new(list_value: Google::Protobuf::ListValue.new(values: [Google::Protobuf::Value.new(string_value: "production")])) }), param_types: { "dict" => Google::Spanner::V1::Type.new(code: :STRUCT, struct_type: Google::Spanner::V1::StructType.new(fields: [Google::Spanner::V1::StructType::Field.new(name: "env", type: Google::Spanner::V1::Type.new(code: :STRING))])) })
    mock.expect :execute_batch_dml, batch_response_grpc(9), [session_grpc.name, tx_selector, statements, 1, options: default_options]
    session.service.mocked_service = mock

    row_counts = transaction.batch_update do |b|
      b.batch_update "UPDATE users SET active = @active", params: { active: true }
      b.batch_update "UPDATE users SET age = @age", params: { age: 29 }
      b.batch_update "UPDATE users SET score = @score", params: { score: 0.9 }
      b.batch_update "UPDATE users SET updated_at = @updated_at", params: { updated_at: timestamp }
      b.batch_update "UPDATE users SET birthday = @birthday", params: { birthday: date }
      b.batch_update "UPDATE users SET name = @name", params: { name: "Charlie" }
      b.batch_update "UPDATE users SET avatar = @avatar", params: { avatar: file }
      b.batch_update "UPDATE users SET project_ids = @list", params: { list: [1,2,3] }
      b.batch_update "UPDATE users SET settings = @dict", params: { dict: { env: :production } }
    end

    mock.verify

    row_counts.count.must_equal 9
    row_counts.first.must_equal 1
    row_counts.last.must_equal 1
  end

  it "raises ArgumentError if no block is provided" do
    err = expect do
      transaction.batch_update
    end.must_raise ArgumentError
    err.message.must_equal "block is required"
  end

  describe "when used with execute_update" do
    def results_grpc
      Google::Spanner::V1::PartialResultSet.new(
        metadata: Google::Spanner::V1::ResultSetMetadata.new(
          row_type: Google::Spanner::V1::StructType.new(
            fields: []
          )
        ),
        values: [],
        stats: Google::Spanner::V1::ResultSetStats.new(
          row_count_exact: 1
        )
      )
    end

    def results_enum
      Array(results_grpc).to_enum
    end

    it "increases seqno for each request" do
      mock = Minitest::Mock.new
      mock.expect :execute_streaming_sql, results_enum, [session_grpc.name, "UPDATE users SET active = true", transaction: tx_selector, params: nil, param_types: nil, resume_token: nil, partition_token: nil, seqno: 1, options: default_options]
      statement = statement_grpc("UPDATE users SET age = @age", params: Google::Protobuf::Struct.new(fields: { "age" => Google::Protobuf::Value.new(string_value: "29") }), param_types: { "age" => Google::Spanner::V1::Type.new(code: :INT64) })
      mock.expect :execute_batch_dml, batch_response_grpc, [session_grpc.name, tx_selector, [statement], 2, options: default_options]
      mock.expect :execute_streaming_sql, results_enum, [session_grpc.name, "UPDATE users SET active = false", transaction: tx_selector, params: nil, param_types: nil, resume_token: nil, partition_token: nil, seqno: 3, options: default_options]
      session.service.mocked_service = mock

      transaction.execute_update "UPDATE users SET active = true"
      transaction.batch_update do |b|
        b.batch_update "UPDATE users SET age = @age", params: { age: 29 }
      end
      transaction.execute_update "UPDATE users SET active = false"

      mock.verify
    end
  end

  def statement_grpc sql, params: nil, param_types: {}
    Google::Spanner::V1::ExecuteBatchDmlRequest::Statement.new \
      sql: sql, params: params, param_types: param_types
  end

  def batch_result_sets_grpc count, row_count_exact: 1
    count.times.map do
      Google::Spanner::V1::ResultSet.new(
        stats: Google::Spanner::V1::ResultSetStats.new(
          row_count_exact: row_count_exact
        )
      )
    end
  end

  def batch_response_grpc count = 1
    Google::Spanner::V1::ExecuteBatchDmlResponse.new(
      result_sets: batch_result_sets_grpc(count),
      status: Google::Rpc::Status.new(code: 0)
    )
  end
end
