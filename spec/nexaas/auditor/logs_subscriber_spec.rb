require 'spec_helper'

describe Nexaas::Auditor::LogsSubscriber do

  it 'does inherits from Subscriber' do
    expect(subject).to be_kind_of(Nexaas::Auditor::Subscriber)
  end

  describe '#logger' do
    let(:logger) { double('AuditLogger') }
    it 'uses the auditor statistics logger' do
      expect(Nexaas::Auditor).to receive(:logger).and_return(logger)
      expect(subject.logger).to eq(logger)
    end
  end

end

class TestLogsSubscriber < Nexaas::Auditor::LogsSubscriber
  def self.pattern
    /\Aapp\.users\..+\Z/
  end
  # event name = 'app.users.login.success'
  def log_event_app_users_login_success(name, start, finish, event_id, payload)
    [true, name, start, finish, event_id, payload]
  end
end

describe TestLogsSubscriber do

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
      expect(subject).to_not respond_to(:log_event_app_users_some_other_event)
      expect {
        subject.call('app.users.some.other.event', start, finish, 'event_id', {pay: 'load2'})
      }.to_not raise_error
    end
  end

end
