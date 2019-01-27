require 'spec_helper'

describe Oakdex::Pokemon::UseItemService do
  let(:fainted) { false }
  let(:pokemon) { double(:pokemon, fainted?: fainted) }
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
