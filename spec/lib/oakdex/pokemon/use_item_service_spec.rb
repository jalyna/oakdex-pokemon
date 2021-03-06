require 'spec_helper'

describe Oakdex::Pokemon::UseItemService do
  let(:fainted) { false }
  let(:primary_status_condition) { nil }
  let(:level) { 10 }
  let(:move_type_pp) { 10 }
  let(:move_type) { double(:move_type, pp: move_type_pp) }
  let(:move1) { double(:move1, name: 'Move1', move_type: move_type, max_pp: 20) }
  let(:move2) { double(:move2, name: 'Move2', max_pp: 30) }
  let(:moves) { [move1, move2] }
  let(:pokemon) do
    double(:pokemon,
      level: level,
      fainted?: fainted,
      primary_status_condition: primary_status_condition,
      moves: moves)
  end
  let(:item_id) { 'My Item' }
  let(:effects) { [] }
  let(:item) { double(:item, name: item_id, effects: effects) }
  let(:options) { {} }

  subject { described_class.new(pokemon, item_id, options) }

  before do
    allow(Oakdex::Pokedex::Item).to receive(:find!)
      .with(item_id).and_return(item)
  end

  describe '#usable?' do
    let(:item_id) { 'Leaf Stone' }
    let(:evolution) { nil }
    let(:evolution_matcher) { double(:evolution_matcher, evolution: evolution) }

    before do
      allow(Oakdex::Pokemon::EvolutionMatcher).to receive(:new)
        .with(pokemon, 'item', item_id: 'Leaf Stone').and_return(evolution_matcher)
    end

    it { expect(subject).not_to be_usable }

    context 'evolution by item' do
      let(:evolution) { 'New Pokemon' }
      it { expect(subject).to be_usable }
    end

    context 'with effects' do
      let(:condition) { 'Always' }
      let(:target) { 'Single Pokemon' }
      let(:additional_pokemon_change) { {} }
      let(:change_by_key) { 'change_by' }
      let(:effect_options) do
        {
          'pokemon_changes' => [
            {
              'field' => 'current_hp',
              "#{change_by_key}" => 20
            }.merge(additional_pokemon_change)
          ]
        }
      end
      let(:effects) do
        [{
          'condition' => condition,
          'target' => target
        }.merge(effect_options)]
      end

      let(:current_hp) { 20 }

      before do
        allow(pokemon).to receive(:hp).and_return(20)
        allow(pokemon).to receive(:current_hp).and_return(current_hp)
      end

      it { expect(subject).not_to be_usable }

      context 'change level (like with rare candy)' do
        let(:additional_pokemon_change) do
          {
            'field' => 'level',
            'change_by' => 1
          }
        end

        it { expect(subject).to be_usable }

        context 'pokemon is level 100' do
          let(:level) { 100 }

          it { expect(subject).not_to be_usable }
        end
      end

      context 'increase ev (like vitamins or wings)' do
        let(:additional_pokemon_change) do
          {
            'field' => 'ev_atk',
            'change_by' => 10
          }
        end

        before do
          allow(pokemon).to receive(:ev_max?)
            .with(:atk).and_return(false)
        end

        it { expect(subject).to be_usable }

        context 'pokemon has max ev' do
          before do
            allow(pokemon).to receive(:ev_max?)
              .with(:atk).and_return(true)
          end

          it { expect(subject).not_to be_usable }
        end
      end

      context 'increases pp (like max ether)' do
        let(:effect_options) do
          {
            'move_changes' => [
              {
                'field' => 'pp',
                'change_by_percent' => 50
              }
            ]
          }
        end

        before do
          allow(move1).to receive(:pp_max?).and_return(true)
          allow(move2).to receive(:pp_max?).and_return(true)
        end

        it { expect(subject).not_to be_usable }

        context 'pp is not at max' do
          before do
            allow(move1).to receive(:pp_max?).and_return(false)
          end

          it { expect(subject).to be_usable }
        end
      end

      context 'increase pp_max (like pp up)' do
        let(:effect_options) do
          {
            'move_changes' => [
              {
                'field' => 'max_pp',
                'change_by_percent' => 20,
                'change_by_max' => 3
              }
            ]
          }
        end

        before do
          allow(move1).to receive(:max_pp_at_max?).and_return(false)
          allow(move2).to receive(:max_pp_at_max?).and_return(true)
        end

        it { expect(subject).to be_usable }

        context 'pokemon has all moves on max pp' do
          before do
            allow(move1).to receive(:max_pp_at_max?).and_return(true)
          end

          it { expect(subject).not_to be_usable }
        end
      end

      context 'removes status condition' do
        let(:effect_options) do
          {
            'pokemon_changes' => [
              {
                'field' => 'status_condition',
                'change' => 'remove',
                'conditions' => ['poison', 'paralysis']
              }.merge(additional_pokemon_change)
            ]
          }
        end
        it { expect(subject).not_to be_usable }

        context 'infected with paralysis' do
          let(:primary_status_condition) { 'paralysis' }
          it { expect(subject).to be_usable }
        end

        context 'infected with sleep' do
          let(:primary_status_condition) { 'sleep' }
          it { expect(subject).not_to be_usable }
        end
      end

      context 'not full hp' do
        let(:current_hp) { 10 }
        it { expect(subject).to be_usable }

        context 'change_by_percent' do
          let(:change_by_key) { 'change_by_percent' }
          it { expect(subject).to be_usable }
        end

        context 'fainted' do
          let(:fainted) { true }
          it { expect(subject).not_to be_usable }

          context 'is revive' do
            let(:additional_pokemon_change) { { 'revive' => true } }
            it { expect(subject).to be_usable }
          end
        end

        context 'target is trainer' do
          let(:target) { 'Trainer' }
          it { expect(subject).not_to be_usable }
        end

        context 'condition is During Battle' do
          let(:condition) { 'During Battle' }
          it { expect(subject).not_to be_usable }

          context 'in battle' do
            let(:options) { { in_battle: true } }
            it { expect(subject).to be_usable }
          end
        end

        context 'condition is Outside of Battle' do
          let(:condition) { 'Outside of Battle' }
          it { expect(subject).to be_usable }

          context 'in battle' do
            let(:options) { { in_battle: true } }
            it { expect(subject).not_to be_usable }
          end
        end
      end
    end
  end

  describe '#use' do
    let(:item_id) { 'Leaf Stone' }
    let(:evolution) { nil }
    let(:evolution_matcher) { double(:evolution_matcher, evolution: evolution) }

    before do
      allow(Oakdex::Pokemon::EvolutionMatcher).to receive(:new)
        .with(pokemon, 'item', item_id: 'Leaf Stone').and_return(evolution_matcher)
    end

    it { expect(subject.use).to be_nil }

    context 'evolution by item' do
      let(:evolution) { 'NewPokemon' }

      it 'creates growth event' do
        expect(pokemon).to receive(:add_growth_event)
          .with(Oakdex::Pokemon::GrowthEvents::Evolution, evolution: 'NewPokemon')
        expect(subject.use).to be(true)
      end
    end

    context 'with effects' do
      let(:condition) { 'Always' }
      let(:target) { 'Single Pokemon' }
      let(:additional_pokemon_change) { {} }
      let(:change_by_key) { 'change_by' }
      let(:effect_options) do
        {
          'pokemon_changes' => [
            {
              'field' => 'current_hp',
              "#{change_by_key}" => 20
            }.merge(additional_pokemon_change)
          ]
        }
      end
      let(:effects) do
        [{
          'condition' => condition,
          'target' => target
        }.merge(effect_options)]
      end

      let(:current_hp) { 8 }

      before do
        allow(pokemon).to receive(:hp).and_return(20)
        allow(pokemon).to receive(:current_hp).and_return(current_hp)
      end

      context 'change level (like with rare candy)' do
        let(:additional_pokemon_change) do
          {
            'field' => 'level',
            'change_by' => 1
          }
        end

        it 'calls increment_level' do
          expect(pokemon).to receive(:increment_level)
          expect(subject.use).to be(true)
        end
      end

      context 'increase ev (like vitamins or wings)' do
        let(:additional_pokemon_change) do
          {
            'field' => 'ev_atk',
            'change_by' => 10
          }
        end

        before do
          allow(pokemon).to receive(:ev_max?)
            .with(:atk).and_return(false)
        end

        it 'calls add_ev' do
          expect(pokemon).to receive(:add_ev).with(:atk, 10)
          expect(subject.use).to be(true)
        end
      end

      context 'increase pp_max (like pp up)' do
        let(:effect_options) do
          {
            'move_changes' => [
              {
                'field' => 'max_pp',
                'change_by_percent' => 20,
                'change_by_max' => 3
              }
            ]
          }
        end

        before do
          allow(move1).to receive(:max_pp_at_max?).and_return(false)
          allow(move2).to receive(:max_pp_at_max?).and_return(true)
        end

        it 'creates growth event' do
          expect(pokemon).to receive(:add_growth_event)
            .with(Oakdex::Pokemon::GrowthEvents::IncreaseMaxPp, moves: {
              move1.name => 2
            })
          expect(subject.use).to be(true)
        end

        context 'pp gain is bigger than max change 3' do
          let(:move_type_pp) { 30 }

          it 'creates growth event' do
            expect(pokemon).to receive(:add_growth_event)
              .with(Oakdex::Pokemon::GrowthEvents::IncreaseMaxPp, moves: {
                move1.name => 3
              })
            expect(subject.use).to be(true)
          end
        end
      end

      context 'increases pp (like max ether)' do
        let(:effect_options) do
          {
            'move_changes' => [
              {
                'field' => 'pp',
                'change_by_percent' => 50
              }
            ]
          }
        end

        before do
          allow(move1).to receive(:pp_max?).and_return(false)
          allow(move2).to receive(:pp_max?).and_return(true)
        end

        it 'creates growth event' do
          expect(pokemon).to receive(:add_growth_event)
            .with(Oakdex::Pokemon::GrowthEvents::IncreasePp, moves: {
              move1.name => 10
            })
          expect(subject.use).to be(true)
        end

        context 'all moves are target' do
          let(:target) { 'Single Pokemon > All Moves' }

          before do
            allow(move1).to receive(:pp_max?).and_return(false)
            allow(move2).to receive(:pp_max?).and_return(false)
          end

          it 'creates growth event' do
            expect(pokemon).to receive(:add_growth_event)
              .with(Oakdex::Pokemon::GrowthEvents::IncreaseMovePp, move_id: move1.name, change_by: 10)
            expect(pokemon).to receive(:add_growth_event)
              .with(Oakdex::Pokemon::GrowthEvents::IncreaseMovePp, move_id: move2.name, change_by: 15)
            expect(subject.use).to be(true)
          end
        end
      end

      context 'removes status condition' do
        let(:primary_status_condition) { 'paralysis' }
        let(:effect_options) do
          {
            'pokemon_changes' => [
              {
                'field' => 'status_condition',
                'change' => 'remove',
                'conditions' => ['poison', 'paralysis']
              }.merge(additional_pokemon_change)
            ]
          }
        end

        it 'creates growth event' do
          expect(pokemon).to receive(:add_growth_event)
            .with(Oakdex::Pokemon::GrowthEvents::RemoveStatusCondition)
          expect(subject.use).to be(true)
        end
      end

      it 'creates growth event' do
        expect(pokemon).to receive(:add_growth_event)
          .with(Oakdex::Pokemon::GrowthEvents::AddHp, hp: 20)
        expect(subject.use).to be(true)
      end

      context 'by percent' do
        let(:change_by_key) { 'change_by_percent' }

        it 'creates growth event' do
          expect(pokemon).to receive(:add_growth_event)
            .with(Oakdex::Pokemon::GrowthEvents::AddHp, hp: 4)
          expect(subject.use).to be(true)
        end
      end

      context 'revive' do
        let(:fainted) { true }
        let(:current_hp) { 0 }
        let(:additional_pokemon_change) { { 'revive' => true } }

        it 'creates growth event' do
          expect(pokemon).to receive(:add_growth_event)
            .with(Oakdex::Pokemon::GrowthEvents::Revive, hp: 20)
          expect(subject.use).to be(true)
        end
      end
    end
  end
end
