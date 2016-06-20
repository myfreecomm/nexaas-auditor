require 'spec_helper'

describe Nexaas::Auditor::Subscriber do

  describe '.subscribe_all' do
    it 'raises an error if no subclasses are found (on the Rails app)' do
      expect(described_class).to receive(:subclasses).and_return([])
      expect { described_class.subscribe_all }.
        to raise_error(RuntimeError, "no subclasses of Nexaas::Auditor::Subscriber found!")
    end
    it 'calls `.subscribe` in all subclasses and returns the results as an array' do
      expect(described_class).to receive(:subclasses).at_least(1).times.and_return(
        [double('subclass 1', subscribe: 'ok 1'), double('subclass 2', subscribe: 'ok 2')]
      )
      expect(described_class.subscribe_all).to eq(['ok 1', 'ok 2'])
    end
  end

  describe '.subscribe' do
    before do
      expect(described_class).to receive(:pattern).and_return(/somepattern/)
    end
    it 'subscribes to the events with partner, passing a new instance of itself' do
      expect(::ActiveSupport::Notifications).
        to receive(:subscribe).
        with(/somepattern/, an_instance_of(described_class))
      described_class.subscribe
    end
    it 'allows to use a different instrumentation class' do
      other_subscriber = double('SomeOtherClass', subscribe: true)
      expect(other_subscriber).
        to receive(:subscribe).
        with(/somepattern/, an_instance_of(described_class))
      described_class.subscribe(subscriber: other_subscriber)
    end
  end

  it 'requires re-implementation of .pattern on a subclass' do
    expect { described_class.pattern }.
      to raise_error(RuntimeError)
  end

  it 'requires re-implementation of #event_method_name on a subclass' do
    expect { subject.send(:event_method_name, 'some name') }.
      to raise_error(RuntimeError)
  end

end
