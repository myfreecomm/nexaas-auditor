require 'spec_helper'

describe Nexaas::Auditor::Configuration do

  it 'instanciates a new object with default attr values' do
    config = described_class.new
    expect(config.enabled).to be_nil
    expect(config.log_app_events).to be_falsy
    expect(config.track_app_events).to be_falsy
    expect(config.track_rails_events).to be_falsy
    expect(config.statistics_namespace).to be_nil
    expect(config.statistics_service).to eq('log')
    expect(config.stathat_settings).to eq({key: nil})
    expect(config.logger).to_not be_nil
    expect(config.logger).to be_instance_of(::Logger)
  end

  it 'allows attributes to be read like a hash' do
    expect(subject[:statistics_service]).to eq('log')
    expect(subject['stathat_settings']).to eq({key: nil})
  end

  it 'allows settings to be changed' do
    expect(subject.statistics_service).to eq('log')
    subject.statistics_service = 'stathat'
    expect(subject.statistics_service).to eq('stathat')
  end
end
