require 'spec_helper'

describe Oakdex::Pokemon::GrowthEvents::AddHp do
  let(:pokemon) { double(:pokemon, name: 'Beauty', hp: 20, current_hp: 8) }
  let(:options) { { hp: 15 } }
  subject { described_class.new(pokemon, options) }

  describe '#message' do
    it { expect(subject.message)
      .to eq('Beauty heals by 12HP.') }
  end


  describe '#execute' do
    it 'removes growth event and changes hp of pokemon' do
      expect(pokemon).to receive(:change_hp_by).with(15)
      expect(pokemon).to receive(:remove_growth_event)
      subject.execute
    end
  end
end
