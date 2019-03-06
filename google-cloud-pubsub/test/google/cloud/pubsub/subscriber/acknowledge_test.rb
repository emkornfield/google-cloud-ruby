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

describe Google::Cloud::PubSub::Subscriber, :acknowledge, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_hash) { subscription_hash topic_name, sub_name }
  let(:sub_grpc) { Google::Cloud::PubSub::V1::Subscription.new(sub_hash) }
  let(:sub_path) { sub_grpc.name }
  let(:subscription) { Google::Cloud::PubSub::Subscription.from_grpc sub_grpc, pubsub.service }
  let(:rec_msg1_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                          rec_message_hash("rec_message1-msg-goes-here", 1111) }
  let(:rec_msg2_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                          rec_message_hash("rec_message2-msg-goes-here", 1112) }
  let(:rec_msg3_grpc) { Google::Cloud::PubSub::V1::ReceivedMessage.new \
                          rec_message_hash("rec_message3-msg-goes-here", 1113) }

  it "can acknowledge a single message" do
    rec_message_msg = "pulled-message"
    rec_message_ack_id = 123456789
    pull_res = Google::Cloud::PubSub::V1::StreamingPullResponse.new rec_messages_hash(rec_message_msg, rec_message_ack_id)
    response_groups = [[pull_res]]

    stub = StreamingPullStub.new response_groups
    called = false

    subscription.service.mocked_subscriber = stub
    subscriber = subscription.listen streams: 1 do |result|
      # flush the initial buffer before any callbacks are processed
      subscriber.buffer.flush! unless called

      assert_kind_of Google::Cloud::PubSub::ReceivedMessage, result
      assert_equal rec_message_msg, result.data
      assert_equal "ack-id-#{rec_message_ack_id}", result.ack_id

      result.ack!
      called = true
    end
    subscriber.start

    subscriber_retries = 0
    while !called
      fail "total number of calls were never made" if subscriber_retries > 100
      subscriber_retries += 1
      sleep 0.01
    end

    subscriber.stop
    subscriber.wait!

    stub.requests.map(&:to_a).must_equal [
      [Google::Cloud::PubSub::V1::StreamingPullRequest.new(
        subscription: sub_path,
        stream_ack_deadline_seconds: 60
      )]
    ]
    stub.acknowledge_requests.must_equal [
      [sub_path, ["ack-id-123456789"]]
    ]
    stub.modify_ack_deadline_requests.must_equal [
      [sub_path, ["ack-id-123456789"], 60]
    ]
  end

  it "can acknowledge multiple messages" do
    pull_res = Google::Cloud::PubSub::V1::StreamingPullResponse.new received_messages: [rec_msg1_grpc, rec_msg2_grpc, rec_msg3_grpc]
    response_groups = [[pull_res]]

    stub = StreamingPullStub.new response_groups
    called = 0

    subscription.service.mocked_subscriber = stub
    subscriber = subscription.listen streams: 1 do |msg|
      # flush the initial buffer before any callbacks are processed
      subscriber.buffer.flush! if called.zero?

      assert_kind_of Google::Cloud::PubSub::ReceivedMessage, msg
      msg.ack!
      called +=1
    end
    subscriber.start

    subscriber_retries = 0
    while called < 3
      fail "total number of calls were never made" if subscriber_retries > 100
      subscriber_retries += 1
      sleep 0.01
    end

    subscriber.stop
    subscriber.wait!

    stub.requests.map(&:to_a).must_equal [
      [Google::Cloud::PubSub::V1::StreamingPullRequest.new(
        subscription: sub_path,
        stream_ack_deadline_seconds: 60
      )]
    ]
    stub.acknowledge_requests.must_equal [
      [sub_path, ["ack-id-1111", "ack-id-1112", "ack-id-1113"]]
    ]
    stub.modify_ack_deadline_requests.must_equal [
      [sub_path, ["ack-id-1111", "ack-id-1112", "ack-id-1113"], 60]
    ]
  end
end
