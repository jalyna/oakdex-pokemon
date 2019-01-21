require 'spec_helper'

describe Oakdex::Pokemon::GrowthEvents::LearnMove do
  let(:move) { double(:move, name: 'MyMove') }
  let(:move2) { double(:move2, name: 'MyMove2') }
  let(:move3) { double(:move3, name: 'MyMove3') }
  let(:move4) { double(:move4, name: 'MyMove4') }
  let(:moves) { [] }
  let(:pokemon) { double(:pokemon, name: 'Beauty', moves: moves) }
  let(:options) { { move_id: 'Tackle' } }
  subject { described_class.new(pokemon, options) }

  describe '#message' do
    it { expect(subject.message)
      .to eq('Beauty learned Tackle.') }

    context 'no slot left' do
      let(:moves) { [move, move, move, move] }
      it { expect(subject.message)
        .to eq('Beauty wants to learn Tackle but has already 4 moves.') }
    end
  end

  describe '#possible_actions' do
    it { expect(subject.possible_actions).to be_empty }

    context 'no slot left' do
      let(:moves) { [move, move2, move3, move4] }
      it { expect(subject.possible_actions)
        .to eq(['Do not learn Tackle',
          'Forget MyMove',
          'Forget MyMove2',
          'Forget MyMove3',
          'Forget MyMove4']) }
    end
  end

  describe '#execute' do
    it 'pokemon learns new move' do
      expect(pokemon).to receive(:learn_new_move).with('Tackle')
      expect(pokemon).to receive(:remove_growth_event)
      subject.execute
    end

    context 'no slot left' do
      let(:moves) { [move, move2, move3, move4] }
      
      it 'does not learn the move' do
        expect(pokemon).to receive(:add_growth_event)
          .with(Oakdex::Pokemon::GrowthEvents::DidNotLearnMove,
            move_id: 'Tackle', after: subject)
        expect(pokemon).to receive(:remove_growth_event)
        subject.execute('Do not learn Tackle')
      end
      
      it 'replaces other move' do
        expect(pokemon).to receive(:learn_new_move).with('Tackle', 'MyMove')
        expect(pokemon).to receive(:add_growth_event)
          .with(Oakdex::Pokemon::GrowthEvents::ForgotAndLearnedMove,
            move_id: 'Tackle', forgot_move_id: 'MyMove', after: subject)
        expect(pokemon).to receive(:remove_growth_event)
        subject.execute('Forget MyMove')
      end
    end
  end
end
