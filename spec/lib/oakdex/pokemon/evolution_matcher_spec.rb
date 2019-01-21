require 'spec_helper'

describe Oakdex::Pokemon::EvolutionMatcher do
  let(:evolution) do
    {
      'level' => 12,
      'to' => 'Destination'
    }
  end
  let(:evolutions) { [evolution] }
  let(:moves) { [] }
  let(:species) do
    double(:species, evolutions: evolutions)
  end
  let(:level) { 13 }
  let(:friendship) { 70 }
  let(:item_id) { 'Some Item' }
  let(:gender) { 'male' }
  let(:atk) { 15 }
  let(:defense) { 12 }
  let(:pokemon) do
    double(:pokemon,
      species: species,
      level: level,
      friendship: friendship,
      item_id: item_id,
      gender: gender,
      atk: atk,
      def: defense,
      moves: moves
    )
  end
  let(:trigger) { 'level_up' }
  let(:options) { {} }
  subject { described_class.new(pokemon, trigger, options) }

  describe '#evolution' do
    it { expect(subject.evolution).to eq('Destination') }

    context 'given level is too low' do
      let(:level) { 11 }
      it { expect(subject.evolution).to be_nil }
    end

    context 'happiness original trigger' do
      let(:evolution) do
        {
          'happiness' => true,
          'to' => 'Destination'
        }
      end

      it { expect(subject.evolution).to be_nil }

      context 'enough happiness' do
        let(:friendship) { 222 }
        it { expect(subject.evolution).to eq('Destination') }
      end
    end

    context 'with evolution with holding item' do
      let(:evolution) do
        {
          'level' => 12,
          'to' => 'Destination',
          'hold_item' => 'Shelmet'
        }
      end

      it { expect(subject.evolution).to be_nil }

      context 'pokemon holds item' do
        let(:item_id) { 'Shelmet' }
        it { expect(subject.evolution).to eq('Destination') }
      end
    end

    context 'with evolution move learned' do
      let(:evolution) do
        {
          'level' => 12,
          'to' => 'Destination',
          'move_learned' => 'Tackle'
        }
      end

      it { expect(subject.evolution).to be_nil }

      context 'pokemon has tackle' do
        let(:moves) { [double(:move, name: 'Tackle')] }
        it { expect(subject.evolution).to eq('Destination') }
      end
    end

    context 'with evolution conditions' do
      let(:evolution) do
        {
          'level' => 12,
          'to' => 'Destination',
          'conditions' => ['Female', 'Attack = Defense']
        }
      end

      it { expect(subject.evolution).to be_nil }

      context 'pokemon is female' do
        let(:gender) { 'female' }
        it { expect(subject.evolution).to be_nil }

        context 'pokemon atk is defense' do
          let(:defense) { atk }
          it { expect(subject.evolution).to eq('Destination') }
        end
      end
    end

    context 'trigger is item' do
      let(:trigger) { 'item' }
      it { expect(subject.evolution).to be_nil }

      context 'item evolution' do
        let(:evolution) do
          {
            'item' => 'Water Stone',
            'to' => 'Destination'
          }
        end
        it { expect(subject.evolution).to be_nil }

        context 'correct item given' do
          let(:options) { { item_id: 'Water Stone' } }
          it { expect(subject.evolution).to eq('Destination') }
        end
      end
    end

    context 'trigger is trade' do
      let(:trigger) { 'trade' }
      it { expect(subject.evolution).to be_nil }

      context 'trade evolution' do
        let(:evolution) do
          {
            'trade' => true,
            'to' => 'Destination'
          }
        end
        it { expect(subject.evolution).to eq('Destination') }
      end
    end

    context 'trigger is move_learned' do
      let(:trigger) { 'move_learned' }
      it { expect(subject.evolution).to be_nil }

      context 'evolution with move learned' do
        let(:evolution) do
          {
            'to' => 'Destination',
            'move_learned' => 'Tackle'
          }
        end

        it { expect(subject.evolution).to be_nil }

        context 'pokemon has tackle' do
          let(:moves) { [double(:move, name: 'Tackle')] }
          it { expect(subject.evolution).to eq('Destination') }
        end
      end
    end
  end
end
