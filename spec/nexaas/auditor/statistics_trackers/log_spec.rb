require 'spec_helper'

describe Nexaas::Auditor::StatisticsTrackers::Log do
  let(:logger) { ::Logger.new(STDERR) }
  subject { described_class.new(logger, 'myapp') }

  it 'inherits from Base' do
    expect(subject).to be_kind_of(Nexaas::Auditor::StatisticsTrackers::Base)
  end

  describe '#track_count' do
    it 'logs the count metric' do
      expect(logger).
        to receive(:info).
        with("[Nexaas::Auditor::StatisticsTrackers::Log] type=count metric=myapp.foo.bar value=42")
      subject.track_count('foo.bar', 42)
    end
    it 'assumes 1 if value is not supplied' do
      expect(logger).
        to receive(:info).
        with("[Nexaas::Auditor::StatisticsTrackers::Log] type=count metric=myapp.foo.bar value=1")
      subject.track_count('foo.bar')
    end
    pending 'validate value'
    pending 'validate name'
  end

  describe '#track_value' do
    it 'logs the value metric' do
      expect(logger).
        to receive(:info).
        with("[Nexaas::Auditor::StatisticsTrackers::Log] type=value metric=myapp.foo.bar value=42.5")
      subject.track_value('foo.bar', 42.5)
    end
    pending 'validate value'
    pending 'validate name'
  end

end
