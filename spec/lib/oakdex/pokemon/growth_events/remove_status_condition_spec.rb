require 'spec_helper'

describe Oakdex::Pokemon::GrowthEvents::RemoveStatusCondition do
  let(:pokemon) { double(:pokemon, name: 'Beauty', primary_status_condition: 'sleep') }
  let(:options) { { hp: 15 } }
  subject { described_class.new(pokemon, options) }

  describe '#message' do
    it { expect(subject.message)
      .to eq('Beauty heals sleep.') }
  end


  describe '#execute' do
    it 'removes growth event and changes primary_status_condition' do
      expect(pokemon).to receive(:primary_status_condition=).with(nil)
      expect(pokemon).to receive(:remove_growth_event)
      subject.execute
    end
  end
end
