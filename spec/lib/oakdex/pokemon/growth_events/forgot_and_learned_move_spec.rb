require 'spec_helper'

describe Oakdex::Pokemon::GrowthEvents::ForgotAndLearnedMove do
  let(:pokemon) { double(:pokemon, name: 'Beauty') }
  let(:options) { { move_id: 'Tackle', forgot_move_id: 'Thunder Shock' } }
  subject { described_class.new(pokemon, options) }

  describe '#message' do
    it { expect(subject.message)
      .to eq('Beauty learned Tackle and forgot Thunder Shock.') }
  end

  describe '#execute' do
    let(:evolution) { nil }
    let(:evolution_matcher) { double(:evolution_matcher, evolution: evolution) }

    before do
      allow(Oakdex::Pokemon::EvolutionMatcher).to receive(:new)
        .with(pokemon, 'move_learned', move_id: 'Tackle').and_return(evolution_matcher)
    end

    it 'removes growth event' do
      expect(pokemon).to receive(:remove_growth_event)
      subject.execute
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
