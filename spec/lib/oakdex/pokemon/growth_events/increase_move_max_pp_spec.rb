require 'spec_helper'

describe Oakdex::Pokemon::GrowthEvents::IncreaseMoveMaxPp do
  let(:move) { double(:move, name: 'Thundershock') }
  let(:move2) { double(:move2, name: 'Tackle') }
  let(:pokemon) { double(:pokemon, name: 'Beauty', moves: [move, move2]) }
  let(:options) do
    {
      move_id: 'Thundershock',
      change_by: 12
    }
  end
  subject { described_class.new(pokemon, options) }

  describe '#message' do
    it { expect(subject.message)
      .to eq('Beauty increased Max PP for Thundershock.') }
  end

  describe '#execute' do
    it 'icnreases max pp' do
      expect(move).to receive(:add_max_pp).with(12)
      expect(pokemon).to receive(:remove_growth_event)
      subject.execute
    end
  end
end
