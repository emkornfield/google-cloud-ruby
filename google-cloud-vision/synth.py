# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""This script is used to synthesize generated parts of this library."""

import synthtool as s
import synthtool.gcp as gcp
import logging

logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v1_library = gapic.ruby_library(
    'vision', 'v1', artman_output_name='google-cloud-ruby/google-cloud-vision'
)

s.copy(v1_library / 'lib/google/cloud/vision/v1')
s.copy(v1_library / 'lib/google/cloud/vision/v1.rb')
s.copy(v1_library / 'test/google/cloud/vision/v1')

# PERMANENT: Handwritten layer owns Vision.new so low-level clients need to
# use Vision::V1.new instead of Vision.new(version: :v1). Update the examples
# and tests.
# REMOVE when we migrate to gapic-only.
s.replace(
    [
      'lib/google/cloud/vision/v1/image_annotator_client.rb',
      'test/google/cloud/vision/v1/image_annotator_client_test.rb'
    ],
    'require "google/cloud/vision"',
    'require "google/cloud/vision/v1"')
s.replace(
    [
      'lib/google/cloud/vision/v1/image_annotator_client.rb',
      'test/google/cloud/vision/v1/image_annotator_client_test.rb'
    ],
    'Google::Cloud::Vision\\.new\\(version: :v1\\)',
    'Google::Cloud::Vision::V1.new')

# https://github.com/googleapis/gapic-generator/issues/2232
s.replace(
    'lib/google/cloud/vision/v1/image_annotator_client.rb',
    '\n\n(\\s+)class OperationsClient < Google::Longrunning::OperationsClient',
    '\n\n\\1# @private\n\\1class OperationsClient < Google::Longrunning::OperationsClient')

# https://github.com/googleapis/gapic-generator/issues/2243
s.replace(
    'lib/google/cloud/vision/v1/*_client.rb',
    '(\n\\s+class \\w+Client\n)(\\s+)(attr_reader :\\w+_stub)',
    '\\1\\2# @private\n\\2\\3')