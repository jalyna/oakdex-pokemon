require 'spec_helper'

describe Oakdex::Pokemon::GrowthEvents::GainedExp do
  let(:pokemon) { double(:pokemon, name: 'Beauty', level: 5) }
  let(:options) { { gained_exp: 129 } }
  subject { described_class.new(pokemon, options) }

  let(:growth_event1) { double(:growth_event1) }
  let(:growth_event2) { double(:growth_event2) }

  describe '#message' do
    it { expect(subject.message)
      .to eq('Beauty gained 129 EXP.') }
  end

  describe '#execute' do
    it 'adds exp for pokemon' do
      expect(pokemon).to receive(:add_exp).with(129)
      expect(pokemon).to receive(:remove_growth_event)
      subject.execute
    end

    context 'level is raising by 2' do
      before do
        allow(pokemon).to receive(:level).and_return(5, 7)
      end

      it 'adds exp for pokemon and initiates level up' do
        expect(pokemon).to receive(:add_exp).with(129)
        expect(pokemon).to receive(:add_growth_event)
          .with(Oakdex::Pokemon::GrowthEvents::LevelUp,
            new_level: 6, after: subject)
          .and_return(growth_event1)
        expect(pokemon).to receive(:add_growth_event)
          .with(Oakdex::Pokemon::GrowthEvents::LevelUp,
            new_level: 7, after: growth_event1)
          .and_return(growth_event2)

        expect(pokemon).to receive(:remove_growth_event)
        subject.execute
      end
    end
  end
end
