# Copyright 2017 Google LLC
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

describe Google::Cloud::Spanner::Results, :empty_field_names, :mock_spanner do
  let :results_types do
    {
      metadata: {
        row_type: {
          fields: [
            { type: { code: :INT64 } },
            { type: { code: :INT64 } },
            { type: { code: :INT64 } },
            { type: { code: :INT64 } }
          ]
        }
      }
    }
  end
  let :results_values do
    {
      values: [
        { string_value: "1" },
        { string_value: "2" },
        { string_value: "3" },
        { string_value: "4" },
        { string_value: "5" },
        { string_value: "6" },
        { string_value: "7" },
        { string_value: "8" }
      ]
    }
  end
  let(:results_enum) do
    [Google::Spanner::V1::PartialResultSet.new(results_types),
     Google::Spanner::V1::PartialResultSet.new(results_values)].to_enum
  end
  let(:results) { Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service }

  it "handles empty field names" do
    results.must_be_kind_of Google::Cloud::Spanner::Results

    fields = results.fields
    fields.wont_be :nil?
    fields.must_be_kind_of Google::Cloud::Spanner::Fields
    fields.types.must_equal [:INT64, :INT64, :INT64, :INT64]
    fields.keys.must_equal [0, 1, 2, 3]
    fields.pairs.must_equal [[0, :INT64], [1, :INT64], [2, :INT64], [3, :INT64]]
    fields.to_a.must_equal [:INT64, :INT64, :INT64, :INT64]
    fields.to_h.must_equal({ 0=>:INT64, 1=>:INT64, 2=>:INT64, 3=>:INT64 })

    rows = results.rows.to_a # grab them all from the enumerator
    rows.count.must_equal 2
    rows.first.to_a.must_equal [1, 2, 3, 4]
    rows.last.to_a.must_equal [5, 6, 7, 8]
    rows.first.to_h.must_equal({ 0=>1, 1=>2, 2=>3, 3=>4 })
    rows.last.to_h.must_equal({ 0=>5, 1=>6, 2=>7, 3=>8 })
    rows.first.pairs.must_equal [[0, 1], [1, 2], [2, 3], [3, 4]]
    rows.last.pairs.must_equal [[0, 5], [1, 6], [2, 7], [3, 8]]
  end
end
