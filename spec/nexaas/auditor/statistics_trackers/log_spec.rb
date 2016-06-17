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
      subject.track_count(metric: 'foo.bar', value: 42)
    end
    it 'assumes 1 if value is not supplied' do
      expect(logger).
        to receive(:info).
        with("[Nexaas::Auditor::StatisticsTrackers::Log] type=count metric=myapp.foo.bar value=1")
      subject.track_count(metric: 'foo.bar')
    end
    it 'works without a namespace too' do
      other = described_class.new(logger)
      expect(logger).
        to receive(:info).
        with("[Nexaas::Auditor::StatisticsTrackers::Log] type=count metric=foo.bar value=12")
      other.track_count(metric: 'foo.bar', value: 12)
    end
    ['string', '', Time.now, '1'].each do |value|
      it "requires a valid value, not #{value.inspect}" do
        expect { subject.track_count(metric: 'foobar', value: value) }.
          to raise_error(ArgumentError, /unsuported value/)
      end
    end
    [nil, '', Time.now, 'foo/bar', 'foo=bar'].each do |value|
      it "requires a valid metric name, not #{value.inspect}" do
        expect { subject.track_count(metric: value, value: 1) }.
          to raise_error(ArgumentError, /unsuported metric name/)
      end
    end
  end

  describe '#track_value' do
    it 'logs the value metric' do
      expect(logger).
        to receive(:info).
        with("[Nexaas::Auditor::StatisticsTrackers::Log] type=value metric=myapp.foo.bar value=42.5")
      subject.track_value(metric: 'foo.bar', value: 42.5)
    end
    ['string', '', Time.now, '1'].each do |value|
      it "requires a valid value, not #{value.inspect}" do
        expect { subject.track_value(metric: 'foobar', value: value) }.
          to raise_error(ArgumentError, /unsuported value/)
      end
    end
    [nil, '', Time.now, 'foo/bar', 'foo=bar'].each do |value|
      it "requires a valid metric name, not #{value.inspect}" do
        expect { subject.track_value(metric: value, value: 1.0) }.
          to raise_error(ArgumentError, /unsuported metric name/)
      end
    end
  end

end
