require 'spec_helper'

describe Nexaas::Auditor do
  it 'has a version number' do
    expect(Nexaas::Auditor::VERSION).not_to be nil
  end

  it 'delegates .instrument to AS::Notifications' do
    expect(ActiveSupport::Notifications).
      to receive(:instrument).with('foobar', spam: 'eggs')
    described_class.instrument('foobar', spam: 'eggs')
  end

  describe '.configuration' do
    it 'returns a new Configuration object' do
      config = described_class.configuration
      expect(config).to be_instance_of(Nexaas::Auditor::Configuration)
      expect(config.enabled).to be_nil # brand new object, not run through #configure yet
      expect(config.log_app_events).to be_falsy # brand new object, not run through #configure yet
    end
    it 'returns a memoized Configuration object with settings' do
      described_class.configure do |c|
        c.enabled = true
        c.log_app_events = true
      end
      config = described_class.configuration
      expect(config.enabled).to be_truthy
      expect(config.log_app_events).to be_truthy
      config2 = described_class.configuration
      expect(config.object_id).to eql(config2.object_id)
    end
  end

  describe '.subscribe_all' do
    context 'LogsSubscriber' do
      it 'is setup if log_app_events is true' do
        described_class.configure do |c|
          c.log_app_events = true
        end
        expect(Nexaas::Auditor::LogsSubscriber).to receive(:subscribe_all)
        described_class.subscribe_all
      end
      it 'is NOT setup if log_app_events is false' do
        described_class.configure do |c|
          c.log_app_events = false
        end
        expect(Nexaas::Auditor::LogsSubscriber).to_not receive(:subscribe_all)
        described_class.subscribe_all
      end
    end
    context 'StatsSubscriber' do
      it 'is setup if track_app_events is true' do
        described_class.configure do |c|
          c.track_app_events = true
        end
        expect(Nexaas::Auditor::StatsSubscriber).to receive(:subscribe_all)
        described_class.subscribe_all
      end
      it 'is NOT setup if track_app_events is false' do
        described_class.configure do |c|
          c.track_app_events = false
        end
        expect(Nexaas::Auditor::StatsSubscriber).to_not receive(:subscribe_all)
        described_class.subscribe_all
      end
    end
    context 'RailsSubscriber' do
      it 'is setup if track_rails_events is true' do
        described_class.configure do |c|
          c.track_rails_events = true
        end
        expect(Nexaas::Auditor::RailsSubscriber).to receive(:subscribe_all)
        described_class.subscribe_all
      end
      it 'is NOT setup if track_rails_events is false' do
        described_class.configure do |c|
          c.track_rails_events = false
        end
        expect(Nexaas::Auditor::RailsSubscriber).to_not receive(:subscribe_all)
        described_class.subscribe_all
      end
    end
    it 'returns all enabled subscribers' do
      described_class.configure do |c|
        c.log_app_events = true
        c.track_app_events = true
        c.track_rails_events = false
      end
      allow(Nexaas::Auditor::Subscriber).
        to receive(:subscribe_all).
        and_return(['some', 'subscribers'])
      subscribers = described_class.subscribe_all
      expect(subscribers).
        to eql([['some', 'subscribers'], ['some', 'subscribers']])
    end
  end

  describe '.logger' do
    it 'returns an instance of AuditLogger' do
      logger = described_class.logger
      expect(logger).to_not be_nil
      expect(logger).to be_instance_of(Nexaas::Auditor::AuditLogger)
    end
    # TODO how to test the Thread.current stuff?
  end

  describe '.tracker' do
    it 'returns an instance of StatisticsTracker with values from Configuration' do
      tracker = described_class.tracker
      expect(tracker).to_not be_nil
      # because by default we use the 'log' statistics service
      expect(tracker).to be_instance_of(Nexaas::Auditor::StatisticsTrackers::Log)
    end
    # TODO how to test the Thread.current stuff?
  end

end
