require 'spec_helper'

describe Nexaas::Auditor::StatsSubscriber do

  it 'does inherits from Subscriber' do
    expect(subject).to be_kind_of(Nexaas::Auditor::Subscriber)
  end

  describe '#tracker' do
    let(:tracker) { double('StatisticsTracker') }
    it 'uses the auditor statistics tracker' do
      expect(Nexaas::Auditor).to receive(:tracker).and_return(tracker)
      expect(subject.tracker).to eq(tracker)
    end
  end

end

class TestStatsSubscriber < Nexaas::Auditor::StatsSubscriber
  def self.pattern
    /\Aapp\.users\..+\Z/
  end
  # event name = 'app.users.login.success'
  def track_event_app_users_login_success(name, start, finish, event_id, payload)
    [true, name, start, finish, event_id, payload]
  end
end

describe TestStatsSubscriber do

  describe '.pattern' do
    it 'returns the regex used for event subscription' do
      expect(described_class.pattern).to eq(/\Aapp\.users\..+\Z/)
    end
  end

  describe '#call' do
    let(:start) { Time.now - 5 }
    let(:finish) { Time.now }
    it 'dispathes to the appropriate method if it exists' do
      expect(
        subject.call('app.users.login.success', start, finish, 'event_id', {pay: 'load'})
      ).to eq([true, 'app.users.login.success', start, finish, 'event_id', {pay: 'load'}])
    end
    it 'does nothing if no related method exists' do
      expect(subject).to_not respond_to(:track_event_app_users_some_other_event)
      expect {
        subject.call('app.users.some.other.event', start, finish, 'event_id', {pay: 'load2'})
      }.to_not raise_error
    end
  end

end
