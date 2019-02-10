require 'spec_helper'

describe Oakdex::Pokemon::UseItemService do
  let(:fainted) { false }
  let(:primary_status_condition) { nil }
  let(:level) { 10 }
  let(:pokemon) do
    double(:pokemon,
      level: level,
      fainted?: fainted,
      primary_status_condition: primary_status_condition)
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
