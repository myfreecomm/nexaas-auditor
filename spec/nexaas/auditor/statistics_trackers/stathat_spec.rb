require 'spec_helper'

describe Nexaas::Auditor::StatisticsTrackers::Stathat do

  before do
    allow(StatHat::API).to receive(:ez_post_count)
    allow(StatHat::API).to receive(:ez_post_value)
    allow(StatHat::SyncAPI).to receive(:ez_post_count)
    allow(StatHat::SyncAPI).to receive(:ez_post_value)
  end

  subject { described_class.new('ez-key', 'myapp') }

  it 'inherits from Base' do
    expect(subject).to be_kind_of(Nexaas::Auditor::StatisticsTrackers::Base)
  end

  it 'requires a StatHat API key' do
    expect { described_class.new('') }.
      to raise_error(ArgumentError, "required Stathat EZ Key not found")
  end

  describe '#track_count' do
    it 'logs the count metric to debug' do
      expect(subject.logger).
        to receive(:debug).
        with("[Nexaas::Auditor::StatisticsTrackers::Stathat] calling StatHat::SyncAPI.ez_post_count('myapp.foo.bar', 'ez-key', 42)")
      subject.track_count(metric: 'foo.bar', value: 42)
    end
    it 'sends the metric to StatHat' do
      expect(StatHat::SyncAPI).
        to receive(:ez_post_count).with('myapp.foo.bar', 'ez-key', 1337)
      subject.track_count(metric: 'foo.bar', value: 1337)
    end
    it 'assumes 1 if value is not supplied' do
      expect(StatHat::SyncAPI).
        to receive(:ez_post_count).with('myapp.foo.bar', 'ez-key', 1)
      subject.track_count(metric: 'foo.bar')
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

    context "when it encountered an error" do
      before { allow(StatHat::SyncAPI).to receive(:ez_post_count).and_raise(Net::OpenTimeout) }

      it "do not raise an error" do
        expect{ subject.track_count(metric: 'foo.bar', value: 42) }.to_not raise_error
      end
      it "log the error to fatal" do
        expect(subject.logger).
          to receive(:fatal).
          with("role=nexaas-auditor class=Nexaas::Auditor::StatisticsTrackers::Stathat measure=errors.unable_to_track exception=Net::OpenTimeout")
        subject.track_count(metric: 'foo.bar', value: 42)
      end
    end
  end

  describe '#track_value' do
    it 'logs the value metric to debug' do
      expect(subject.logger).
        to receive(:debug).
        with("[Nexaas::Auditor::StatisticsTrackers::Stathat] calling StatHat::SyncAPI.ez_post_value('myapp.foo.bar', 'ez-key', 42.5)")
      subject.track_value(metric: 'foo.bar', value: 42.5)
    end
    it 'sends the metric to StatHat' do
      expect(StatHat::SyncAPI).
        to receive(:ez_post_value).with('myapp.foo.bar', 'ez-key', 13.37)
      subject.track_value(metric: 'foo.bar', value: 13.37)
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

    context "when it encountered an error" do
      before { allow(StatHat::SyncAPI).to receive(:ez_post_value).and_raise(Net::OpenTimeout) }

      it "do not raise an error" do
        expect{ subject.track_value(metric: 'foo.bar', value: 5.0) }.to_not raise_error
      end
      it "log the error to fatal" do
        expect(subject.logger).
          to receive(:fatal).
          with("role=nexaas-auditor class=Nexaas::Auditor::StatisticsTrackers::Stathat measure=errors.unable_to_track exception=Net::OpenTimeout")
        subject.track_value(metric: 'foo.bar', value: 5.0)
      end
    end
  end

end
