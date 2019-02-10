require 'spec_helper'

describe Oakdex::Pokemon::GrowthEvents::IncreaseMaxPp do
  let(:pokemon) { double(:pokemon, name: 'Beauty') }
  let(:options) do
    {
      moves: {
        'Thundershock' => 12
      }
    }
  end
  subject { described_class.new(pokemon, options) }

  describe '#message' do
    it { expect(subject.message)
      .to eq('Please choose a move of Beauty that should increase its Max PP.') }
  end

  describe '#possible_actions' do
    it { expect(subject.possible_actions).to eq(['Thundershock']) }
  end

  describe '#execute' do
    it 'adds growth event' do
      expect(pokemon).to receive(:add_growth_event)
        .with(Oakdex::Pokemon::GrowthEvents::IncreaseMoveMaxPp,
          move_id: 'Thundershock', change_by: 12)
      expect(pokemon).to receive(:remove_growth_event)
      subject.execute('Thundershock')
    end
  end
end
