require 'spec_helper'

describe Oakdex::Pokemon::UseItemService do
  let(:pokemon) { double(:pokemon) }
  let(:item_id) { 'My Item' }
  let(:item) { double(:item, name: item_id) }
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
  end
end
