# Copyright 2016 Google LLC
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

require "google/cloud/pubsub"

class File
  def self.open *args
    "task completed"
  end
end

module Google
  module Cloud
    module PubSub
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
      # Create default unmocked methods that will raise if ever called
      def self.new *args
        raise "This code example is not yet mocked"
      end
      class Credentials
        # Override the default constructor
        def self.new *args
          OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
        end
      end
      class Subscriber
        # doctest has issues running this code, so punt on it completely
        def start
          self
        end
        def stop
          self
        end
        def wait!
          self
        end
      end
    end
  end
end

def mock_pubsub
  Google::Cloud::PubSub.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    pubsub = Google::Cloud::PubSub::Project.new(Google::Cloud::PubSub::Service.new("my-project", credentials))

    pubsub.service.mocked_publisher = Minitest::Mock.new
    pubsub.service.mocked_subscriber = Minitest::Mock.new
    if block_given?
      yield pubsub.service.mocked_publisher, pubsub.service.mocked_subscriber
    end

    pubsub
  end
end

YARD::Doctest.configure do |doctest|
  ##
  # SKIP
  #

  # Skip all GAPIC for now
  doctest.skip "Google::Cloud::PubSub::V1"

  # Skip all aliases, since tests would be exact duplicates
  doctest.skip "Google::Cloud::PubSub::Message#msg_id"
  doctest.skip "Google::Cloud::PubSub::Project#get_topic"
  doctest.skip "Google::Cloud::PubSub::Project#find_topic"
  doctest.skip "Google::Cloud::PubSub::Project#new_topic"
  doctest.skip "Google::Cloud::PubSub::Project#find_topics"
  doctest.skip "Google::Cloud::PubSub::Project#list_topics"
  doctest.skip "Google::Cloud::PubSub::Project#create_subscription"
  doctest.skip "Google::Cloud::PubSub::Project#new_subscription"
  doctest.skip "Google::Cloud::PubSub::Project#get_subscription"
  doctest.skip "Google::Cloud::PubSub::Project#find_subscription"
  doctest.skip "Google::Cloud::PubSub::Project#find_subscriptions"
  doctest.skip "Google::Cloud::PubSub::Project#list_subscriptions"
  doctest.skip "Google::Cloud::PubSub::Project#find_snapshots"
  doctest.skip "Google::Cloud::PubSub::Project#list_snapshots"
  doctest.skip "Google::Cloud::PubSub::Subscription#ack"
  doctest.skip "Google::Cloud::PubSub::Subscription#new_snapshot"
  doctest.skip "Google::Cloud::PubSub::Topic#create_subscription"
  doctest.skip "Google::Cloud::PubSub::Topic#new_subscription"
  doctest.skip "Google::Cloud::PubSub::Topic#get_subscription"
  doctest.skip "Google::Cloud::PubSub::Topic#find_subscription"
  doctest.skip "Google::Cloud::PubSub::Topic#find_subscriptions"
  doctest.skip "Google::Cloud::PubSub::Topic#list_subscriptions"

  doctest.before "Google::Cloud.pubsub" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message], Hash]
    end
  end

  doctest.before "Google::Cloud#pubsub" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message], Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message], Hash]
    end
  end

  doctest.skip "Google::Cloud::PubSub::Credentials" # occasionally getting "This code example is not yet mocked"

  doctest.before "Google::Cloud::PubSub::Message" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message], Hash]
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :streaming_pull, [OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)])].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
    end
  end

  # Policy

  doctest.before "Google::Cloud::PubSub::Policy" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :get_iam_policy, policy_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :set_iam_policy, policy_resp, ["projects/my-project/topics/my-topic", Google::Iam::V1::Policy, Hash]
    end
  end

  ##
  # Project

  doctest.before "Google::Cloud::PubSub::Project" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message("task completed")], Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Project#topic" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/existing-topic", Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Project#topic@By default `nil` will be returned if topic does not exist." do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/non-existing-topic", Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Project#topic@Create topic in a different project with the `project` flag." do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/another-topic", Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Project#topic@Configuring AsyncPublisher to increase concurrent callbacks:" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message("task completed")], Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Project#create_topic" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :create_topic, nil, ["projects/my-project/topics/my-topic", Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Project#topics" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :list_topics, list_topics_paged_enum, ["projects/my-project", Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Project#subscription" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-sub", Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Project#subscriptions" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :list_subscriptions, list_subscriptions_resp, ["projects/my-project", Hash]
      mock_subscriber.expect :list_subscriptions, list_subscriptions_resp(nil), ["projects/my-project", Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Project#snapshots" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :list_snapshots, list_snapshots_resp, ["projects/my-project", Hash]
      mock_subscriber.expect :list_snapshots, list_snapshots_resp(nil), ["projects/my-project", Hash]
    end
  end

  ##
  # ReceivedMessage

  doctest.before "Google::Cloud::PubSub::ReceivedMessage" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :streaming_pull, [OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)])].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :acknowledge, nil, ["projects/my-project/subscriptions/my-sub", ["2"], Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::ReceivedMessage#modify_ack_deadline!" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :streaming_pull, [OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)])].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :modify_ack_deadline, nil, ["projects/my-project/subscriptions/my-sub", ["2"], 120, Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::ReceivedMessage#reject!" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-sub", 100, Hash]
      mock_subscriber.expect :streaming_pull, [OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)])].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
    end
  end
  doctest.before "Google::Cloud::PubSub::ReceivedMessage#nack!" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :streaming_pull, [OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)])].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :modify_ack_deadline, nil, ["projects/my-project/subscriptions/my-sub", ["2"], 0, Hash]
    end
  end
  doctest.before "Google::Cloud::PubSub::ReceivedMessage#ignore!" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :streaming_pull, [OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)])].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :modify_ack_deadline, nil, ["projects/my-project/subscriptions/my-sub", ["2"], 0, Hash]
    end
  end

  ##
  # Snapshot

  doctest.before "Google::Cloud::PubSub::Snapshot" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-sub", Hash]
      mock_subscriber.expect :create_snapshot, snapshot_resp, ["projects/my-project/snapshots/my-snapshot", "projects/my-project/subscriptions/my-sub", Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Snapshot#delete" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :list_snapshots, list_snapshots_resp, ["projects/my-project", Hash]
      mock_subscriber.expect :delete_snapshot, nil, [String, Hash]
      mock_subscriber.expect :delete_snapshot, nil, [String, Hash]
      mock_subscriber.expect :delete_snapshot, nil, [String, Hash]
    end
  end

  ##
  # Snapshot::List

  doctest.before "Google::Cloud::PubSub::Snapshot::List" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :list_snapshots, list_snapshots_resp, ["projects/my-project", Hash]
      mock_subscriber.expect :list_snapshots, list_snapshots_resp(nil), ["projects/my-project", Hash]
    end
  end


  ##
  # Subscription

  doctest.before "Google::Cloud::PubSub::Subscription" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :streaming_pull, [OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)])].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :acknowledge, nil, ["projects/my-project/subscriptions/my-topic-sub", ["2"], Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Subscription#modify_ack_deadline" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-topic-sub", 100, Hash]
      mock_subscriber.expect :modify_ack_deadline, nil, ["projects/my-project/subscriptions/my-topic-sub", ["2"], 120, Hash]
    end
  end
  doctest.before "Google::Cloud::PubSub::Subscription#pull" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-topic-sub", 100, Hash]
      mock_subscriber.expect :acknowledge, nil, ["projects/my-project/subscriptions/my-topic-sub", ["2"], Hash]
    end
  end
  doctest.before "Google::Cloud::PubSub::Subscription#wait_for_messages" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-topic-sub", 100, Hash]
      mock_subscriber.expect :acknowledge, nil, ["projects/my-project/subscriptions/my-topic-sub", ["2"], Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Subscription#delete" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :delete_subscription, subscription_resp, ["projects/my-project/subscriptions/my-topic-sub", Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Subscription#policy" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-subscription"), ["projects/my-project/subscriptions/my-subscription", Hash]
      mock_subscriber.expect :get_iam_policy, policy_resp, ["projects/my-project/subscriptions/my-subscription", Hash]
      mock_subscriber.expect :set_iam_policy, policy_resp, ["projects/my-project/subscriptions/my-subscription", Google::Iam::V1::Policy, Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Subscription#update_policy" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-subscription"), ["projects/my-project/subscriptions/my-subscription", Hash]
      mock_subscriber.expect :get_iam_policy, policy_resp, ["projects/my-project/subscriptions/my-subscription", Hash]
      mock_subscriber.expect :set_iam_policy, policy_resp, ["projects/my-project/subscriptions/my-subscription", Google::Iam::V1::Policy, Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Subscription#pull@A maximum number of messages returned can also be specified:" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-topic-sub", 10, Hash]
      mock_subscriber.expect :acknowledge, nil, ["projects/my-project/subscriptions/my-topic-sub", ["2"], Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Subscription#test_permissions" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-subscription"), ["projects/my-project/subscriptions/my-subscription", Hash]
      mock_subscriber.expect :get_iam_policy, policy_resp, ["projects/my-project/subscriptions/my-subscription", Hash]
      mock_subscriber.expect :test_iam_permissions, subscription_permissions_resp, ["projects/my-project/subscriptions/my-subscription", ["pubsub.subscriptions.get", "pubsub.subscriptions.consume"], Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Subscription#topic" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-topic-sub", 100, Hash]
      mock_subscriber.expect :acknowledge, nil, ["projects/my-project/subscriptions/my-topic-sub", ["2"], Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Subscription#create_snapshot" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-sub", Hash]
      mock_subscriber.expect :create_snapshot, snapshot_resp, ["projects/my-project/snapshots/my-snapshot", "projects/my-project/subscriptions/my-sub", Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Subscription#create_snapshot@Without providing a name:" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp, ["projects/my-project/subscriptions/my-sub", Hash]
      mock_subscriber.expect :create_snapshot, snapshot_resp("gcr-analysis-..."), [nil, "projects/my-project/subscriptions/my-sub", Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Subscription#seek" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-sub"), ["projects/my-project/subscriptions/my-sub", Hash]
      mock_subscriber.expect :create_snapshot, snapshot_resp("gcr-analysis-..."), [nil, "projects/my-project/subscriptions/my-sub", Hash]
      mock_subscriber.expect :pull, OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)]), ["projects/my-project/subscriptions/my-sub", 100, Hash]
      mock_subscriber.expect :acknowledge, nil, ["projects/my-project/subscriptions/my-sub", ["2"], Hash]
      mock_subscriber.expect :seek, nil, ["projects/my-project/subscriptions/my-sub", Hash]
    end
  end

  ##
  # Subscription::List

  doctest.before "Google::Cloud::PubSub::Subscription::List" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :list_subscriptions, list_subscriptions_resp, ["projects/my-project", Hash]
      mock_subscriber.expect :list_subscriptions, list_subscriptions_resp(nil), ["projects/my-project", Hash]
    end
  end

  ##
  # Subscriber

  doctest.before "Google::Cloud::PubSub::Subscriber" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
      mock_subscriber.expect :streaming_pull, [OpenStruct.new(received_messages: [Google::Cloud::PubSub::V1::ReceivedMessage.new(ack_id: "2", message: pubsub_message)])].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :streaming_pull, [].to_enum, [Enumerator, Hash]
      mock_subscriber.expect :acknowledge, nil, ["projects/my-project/subscriptions/my-topic-sub", ["2"], Hash]
    end
  end

  ##
  # Topic

  doctest.before "Google::Cloud::PubSub::Topic" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message("task completed")], Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Topic#delete" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :delete_topic, nil, ["projects/my-project/topics/my-topic", Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Topic#policy" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :get_iam_policy, policy_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :set_iam_policy, policy_resp, ["projects/my-project/topics/my-topic", Google::Iam::V1::Policy, Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Topic#update_policy" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :get_iam_policy, policy_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :set_iam_policy, policy_resp, ["projects/my-project/topics/my-topic", Google::Iam::V1::Policy, Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Topic#publish" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message("task completed")], Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Topic#publish@Additionally, a message can be published with attributes:" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1"]), ["projects/my-project/topics/my-topic", [pubsub_message("task completed", {"foo"=>"bar", "this"=>"that"})], Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Topic#publish@Multiple messages can be sent at the same time using a block:" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      messages = [
        pubsub_message("task 1 completed", { "foo" => "bar" }),
        pubsub_message("task 2 completed", { "foo" => "baz" }),
        pubsub_message("task 3 completed", { "foo" => "bif" })
      ]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1", "2", "3"]), ["projects/my-project/topics/my-topic", messages, Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Topic#subscribe" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_subscriber.expect :create_subscription, OpenStruct.new(name: "my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", "projects/my-project/topics/my-topic", Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Topic#subscription" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_subscriber.expect :get_subscription, subscription_resp("my-topic-sub"), ["projects/my-project/subscriptions/my-topic-sub", Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Topic#subscriptions" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :list_topic_subscriptions, list_topic_subscriptions_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :list_topic_subscriptions, list_topic_subscriptions_resp(nil), ["projects/my-project/topics/my-topic", Hash]
    end
  end

  doctest.before "Google::Cloud::PubSub::Topic#test_permissions" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :get_iam_policy, policy_resp, ["projects/my-project/topics/my-topic", Hash]
      mock_publisher.expect :test_iam_permissions, topic_permissions_resp, ["projects/my-project/topics/my-topic", ["pubsub.topics.get", "pubsub.topics.publish"], Hash]
    end
  end

  ##
  # Topic::List

  doctest.before "Google::Cloud::PubSub::Topic::List" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :list_topics, list_topics_paged_enum, ["projects/my-project", Hash]
    end
  end

  ##
  # BatchPublisher

  doctest.before "Google::Cloud::PubSub::BatchPublisher" do
    mock_pubsub do |mock_publisher, mock_subscriber|
      mock_publisher.expect :get_topic, topic_resp, ["projects/my-project/topics/my-topic", Hash]
      messages = [
        pubsub_message("task 1 completed", { "foo" => "bar" }),
        pubsub_message("task 2 completed", { "foo" => "baz" }),
        pubsub_message("task 3 completed", { "foo" => "bif" })
      ]
      mock_publisher.expect :publish, OpenStruct.new(message_ids: ["1", "2", "3"]), ["projects/my-project/topics/my-topic", messages, Hash]
    end
  end


end

# Fixture helpers

def pubsub_message data = "task completed", attributes = {}
  Google::Cloud::PubSub::V1::PubsubMessage.new data: data, attributes: attributes, message_id: "", publish_time: nil
end

def list_topics_paged_enum
  OpenStruct.new(page: OpenStruct.new(response: OpenStruct.new(topics: [])))
end


def token_options token
  Google::Gax::CallOptions.new(kwargs: { "google-cloud-resource-prefix" => "projects/#{project}" },
                               page_token: token)
end

def topics_hash num_topics, token = ""
  topics = num_topics.times.map do
    topic_hash("topic-#{rand 1000}")
  end
  data = { topics: topics }
  data[:next_page_token] = token unless token.nil?
  data
end

def topic_resp topic_name = "my-topic"
  Google::Cloud::PubSub::V1::Topic.new name: topic_path(topic_name)
end

def topic_subscriptions_hash num_subs, token = nil
  subs = num_subs.times.map do
    subscription_path("sub-#{rand 1000}")
  end
  data = { subscriptions: subs }
  data[:next_page_token] = token unless token.nil?
  data
end

def subscriptions_hash topic_name, num_subs, token = nil
  subs = num_subs.times.map do
    subscription_hash(topic_name, "sub-#{rand 1000}")
  end
  data = { subscriptions: subs }
  data[:next_page_token] = token unless token.nil?
  data
end

def subscription_hash topic_name, sub_name,
                      deadline = 60,
                      endpoint = "http://example.com/callback", labels: nil
  { name: subscription_path(sub_name),
    topic: topic_path(topic_name),
    push_config: { "push_endpoint" => endpoint },
    ack_deadline_seconds: deadline,
    retain_acked_messages: true,
    message_retention_duration: { seconds: 600, nanos: 900000000 }, # 600.9 seconds
    labels: labels
  }
end

def snapshots_hash topic_name, num_snapshots, token = nil
  snapshots = num_snapshots.times.map do
    snapshot_hash(topic_name, "snapshot-#{rand 1000}")
  end
  data = { snapshots: snapshots }
  data[:next_page_token] = token unless token.nil?
  data
end

def snapshot_hash topic_name, snapshot_name, labels: nil
  time = Time.now
  timestamp = {
    seconds: time.to_i,
    nanos: time.nsec
  }
  { name: snapshot_path(snapshot_name),
    topic: topic_path(topic_name),
    expire_time: timestamp,
    labels: labels
  }
end

def rec_message_hash message, id = rand(1000000)
  {
    ack_id: "ack-id-#{id}",
    message: {
      data: Base64.strict_encode64(message),
      attributes: {},
      message_id: "msg-id-#{id}",
    }
  }
end

def rec_messages_hash message, id = nil
  {
    received_messages: [rec_message_hash(message, id)]
  }
end

def project_path
  "projects/my-project"
end

def topic_path topic_name
  "#{project_path}/topics/#{topic_name}"
end

def subscription_path subscription_name
  "#{project_path}/subscriptions/#{subscription_name}"
end

def snapshot_path snapshot_name
  "#{project_path}/snapshots/#{snapshot_name}"
end

def paged_enum_struct response
  OpenStruct.new page: OpenStruct.new(response: response)
end


def subscription_resp name = "my-sub"
  Google::Cloud::PubSub::V1::Subscription.new subscription_hash "my-topic", name
end


def list_subscriptions_resp token = "next_page_token"
  response = Google::Cloud::PubSub::V1::ListSubscriptionsResponse.new subscriptions_hash("my-topic", 3, token)
  paged_enum_struct response
end

def list_topic_subscriptions_resp token = "next_page_token"
  response = Google::Cloud::PubSub::V1::ListTopicSubscriptionsResponse.new topic_subscriptions_hash(3, token)
  paged_enum_struct response
end

def list_snapshots_resp token = "next_page_token"
  response = Google::Cloud::PubSub::V1::ListSnapshotsResponse.new snapshots_hash("my-topic", 3, token)
  paged_enum_struct response
end

def snapshot_resp snapshot_name = "my-snapshot"
  Google::Cloud::PubSub::V1::Snapshot.new snapshot_hash("my-topic", snapshot_name)
end

def policy_resp
  Google::Iam::V1::Policy.new(
    bindings: [
      Google::Iam::V1::Binding.new(
        role: "roles/storage.objectViewer",
        members: [
          "user:viewer@example.com"
        ]
      )
    ]
  )
end

def subscription_permissions_resp
  Google::Iam::V1::TestIamPermissionsResponse.new(
    permissions: ["pubsub.subscriptions.get"]
  )
end

def topic_permissions_resp
  Google::Iam::V1::TestIamPermissionsResponse.new(
    permissions: ["pubsub.topics.get"]
  )
end
