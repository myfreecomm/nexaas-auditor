require 'spec_helper'

describe Nexaas::Auditor::RailsSubscriber do
  it 'does not inherit from Subscriber' do
    expect(subject).to_not be_kind_of(Nexaas::Auditor::Subscriber)
  end

  describe '.subscribe_all' do
    it 'fires all Nunes subscriptions with a wrapped Nunes-compatible tracker' do
      wrapped_tracker = double('Nexaas::Auditor::Adapters::Nunes')
      expect(described_class).to receive(:nunes_statistics_wrapper).and_return(wrapped_tracker)
      expect(::Nunes).to receive(:subscribe).with(wrapped_tracker)
      described_class.subscribe_all
    end
  end

  describe '.nunes_statistics_wrapper' do
    it 'wraps the statistics tracker in a Nunes-compatible adapter' do
      tracker = double('StatisticsTracker')
      expect(Nexaas::Auditor).to receive(:tracker).and_return(tracker)

      wrapped_tracker = described_class.nunes_statistics_wrapper
      expect(wrapped_tracker).to be_instance_of(Nexaas::Auditor::Adapters::Nunes)
      expect(wrapped_tracker.client).to eql(tracker)
    end
  end
end
