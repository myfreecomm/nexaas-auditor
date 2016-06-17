require 'spec_helper'

describe Nexaas::Auditor::AuditLogger do

  it 'instanciates using the logger from the Configuration' do
    logger = double('SomeLogger')
    expect(Nexaas::Auditor).
      to receive_message_chain(:configuration, :logger).
      and_return(logger)
    auditter = described_class.new
    expect(auditter.logger).to eql(logger)
  end

  describe '#log' do
    it 'requires a :level option' do
      expect { subject.log(measure: 'foobar') }.
        to raise_error(ArgumentError, "required key `:level` not found")
    end
    it 'requires a valid :level option' do
      expect { subject.log(level: 'invalid', measure: 'foobar') }.
        to raise_error(ArgumentError, "key `:level` is invalid: 'invalid'")
    end
    it 'requires a :measure option' do
      expect { subject.log(level: 'info') }.
        to raise_error(ArgumentError, "required key 'measure' not found or empty")
    end
    it 'sends the formatted log message to the logger with the correct level' do
      logger = double('SomeLogger')
      expect(subject).to receive(:logger).and_return(logger)
      expect(logger).to receive(:warn).with('audit_log=true measure=foo.bar other=info')
      subject.log(level: :warn, measure: 'foo.bar', other: 'info')
    end
    it 'logs any error and never raises and exception' do
      logger = double('SomeLogger')
      expect(subject).to receive(:logger).at_least(2).times.and_return(logger)

      expect(logger).to receive(:warn).and_raise(RuntimeError, 'some error')
      expect(logger).
        to receive(:fatal).
        with("role=audit_logger class=Nexaas::Auditor::AuditLogger measure=errors.unable_to_log exception=RuntimeError")

      expect {
        subject.log(level: :warn, measure: 'foo.bar', other: 'info')
      }.to_not raise_error
    end
  end

end
