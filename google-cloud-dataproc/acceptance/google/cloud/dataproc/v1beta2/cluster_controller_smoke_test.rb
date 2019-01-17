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

# AUTO GENERATED BY GAPIC

require "minitest/autorun"
require "minitest/spec"

require "google/cloud/dataproc"

describe "ClusterControllerSmokeTest v1beta2" do
  it "runs one smoke test with list_clusters" do
    unless ENV["DATAPROC_TEST_PROJECT"]
      fail "DATAPROC_TEST_PROJECT environment variable must be defined"
    end
    project_id = ENV["DATAPROC_TEST_PROJECT"].freeze

    cluster_controller_client = Google::Cloud::Dataproc::ClusterController.new(version: :v1beta2)
    project_id_2 = project_id
    region = "global"

    # Iterate over all results.
    cluster_controller_client.list_clusters(project_id_2, region).each do |element|
      # Process element.
    end

    # Or iterate over results one page at a time.
    cluster_controller_client.list_clusters(project_id_2, region).each_page do |page|
      # Process each page at a time.
      page.each do |element|
        # Process element.
      end
    end
  end
end