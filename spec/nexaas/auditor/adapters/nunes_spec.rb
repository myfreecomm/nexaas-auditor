require 'spec_helper'

describe Nexaas::Auditor::Adapters::Nunes do
  let(:client) { double('StatisticsTracker', track_count: true, track_value: true) }
  subject { described_class.new(client) }

  it 'inherits from Nunes::Adapter' do
    expect(subject).to be_kind_of(Nunes::Adapter)
  end

  it 'uses the supplied client' do
    expect(subject.client).to eql(client)
  end

  describe '#increment' do
    it 'uses #track_count on the client, with a "rails." prefix' do
      expect(client).to receive(:track_count).with(metric: 'rails.foobar.baz', value: 42)
      subject.increment('foobar baz', 42)
    end
    it 'assumes 1 if value is not supplied' do
      expect(client).to receive(:track_count).with(metric: 'rails.foobar', value: 1)
      subject.increment('foobar')
    end
  end

  describe '#timing' do
    it 'uses #track_value on the client, with a "rails." prefix' do
      expect(client).to receive(:track_value).with(metric: 'rails.foobar.baz', value: 42.5)
      subject.timing('foobar baz', 42.5)
    end
  end

end
