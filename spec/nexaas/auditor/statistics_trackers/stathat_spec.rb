require 'spec_helper'

describe Nexaas::Auditor::StatisticsTrackers::Stathat do
  subject { described_class.new('ez-key', 'myapp') }

  it 'inherits from Base' do
    expect(subject).to be_kind_of(Nexaas::Auditor::StatisticsTrackers::Base)
  end

  describe '#track_count' do
    pending
  end

  describe '#track_value' do
    pending
  end

end
