require 'spec_helper'

describe Oakdex::Pokemon::GrowthEvents::LevelUp do
  let(:learnset) { [] }
  let(:species) { double(:species, learnset: learnset) }
  let(:pokemon) { double(:pokemon, name: 'Beauty', species: species) }
  let(:options) { { new_level: 9 } }
  subject { described_class.new(pokemon, options) }

  let(:growth_event1) { double(:growth_event1) }
  let(:growth_event2) { double(:growth_event2) }

  describe '#message' do
    it { expect(subject.message)
      .to eq('Beauty reached Level 9.') }
  end

  describe '#execute' do
    let(:evolution) { nil }
    let(:evolution_matcher) { double(:evolution_matcher, evolution: evolution) }
    before do
      allow(Oakdex::Pokemon::EvolutionMatcher).to receive(:new)
        .with(pokemon, 'level_up').and_return(evolution_matcher)
    end

    it 'removes last event' do
      expect(pokemon).to receive(:remove_growth_event)
      subject.execute
    end

    context 'new move to learn' do
      let(:learnset) do
        [
          {
            'move' => 'OldMove',
            'level' => 7
          },
          {
            'move' => 'NewMove1',
            'level' => 9
          },
          {
            'move' => 'NewMove2',
            'level' => 9
          }
        ]
      end

      it 'tries to learn new moves' do
        expect(pokemon).to receive(:add_growth_event)
          .with(Oakdex::Pokemon::GrowthEvents::LearnMove,
            move_id: 'NewMove1', after: subject)
          .and_return(growth_event1)
        expect(pokemon).to receive(:add_growth_event)
          .with(Oakdex::Pokemon::GrowthEvents::LearnMove,
            move_id: 'NewMove2', after: growth_event1)
          .and_return(growth_event2)
        expect(pokemon).to receive(:remove_growth_event)
        subject.execute
      end
    end

    context 'evolution available' do
      let(:evolution) { 'SuperBeauty' }

      it 'triggers evolution event' do
        expect(pokemon).to receive(:add_growth_event)
          .with(Oakdex::Pokemon::GrowthEvents::Evolution,
            evolution: 'SuperBeauty', after: subject)
        expect(pokemon).to receive(:remove_growth_event)
        subject.execute
      end
    end
  end
end
