require 'spec_helper'

describe Oakdex::Pokemon::GrowthEvents::Evolution do
  let(:pokemon) { double(:pokemon, name: 'Beauty') }
  let(:options) { { evolution: 'SuperBeauty' } }
  subject { described_class.new(pokemon, options) }

  describe '#message' do
    it { expect(subject.message)
      .to eq('Beauty wants to envolve to SuperBeauty.') }
  end

  describe '#possible_actions' do
    it { expect(subject.possible_actions).to eq(['Continue', 'Skip']) }
  end

  describe '#execute' do
    let(:action) { 'Skip' }

    it 'does nothing' do
      expect(pokemon).to receive(:add_growth_event)
        .with(Oakdex::Pokemon::GrowthEvents::SkippedEvolution,
          after: subject)
      expect(pokemon).to receive(:remove_growth_event)
      subject.execute(action)
    end

    context 'when continue' do
      let(:action) { 'Continue' }

      it 'envolves pokemon' do
        expect(pokemon).to receive(:envolve_to).with('SuperBeauty')
        expect(pokemon).to receive(:add_growth_event)
          .with(Oakdex::Pokemon::GrowthEvents::DidEvolution,
            original: 'Beauty',
            after: subject)
        expect(pokemon).to receive(:remove_growth_event)
        subject.execute(action)
      end
    end
  end
end
