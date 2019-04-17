require 'spec_helper'

describe Nexaas::Auditor::StatisticsTracker do
  describe '.setup' do
    it 'requires a valid service' do
      expect { described_class.setup('foobar') }.
        to raise_error(ArgumentError, "unknown statistics service 'foobar'")
    end
    it 'instanciates a new Stathat tracker' do
      expect(Nexaas::Auditor).
        to receive_message_chain(:configuration, :stathat_settings).
        and_return(key: 'ez-key')
      expect(Nexaas::Auditor::StatisticsTrackers::Stathat).
        to receive(:new).with('ez-key', 'myapp')
      described_class.setup('stathat', 'myapp')
    end
    it 'instanciates a new Log tracker' do
      logger = double('Rails.logger')
      expect(Nexaas::Auditor).
        to receive_message_chain(:configuration, :logger).
        and_return(logger)
      expect(Nexaas::Auditor::StatisticsTrackers::Log).
        to receive(:new).with(logger, 'myapp')
      described_class.setup('log', 'myapp')
    end
  end
end
