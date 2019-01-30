require 'spec_helper'

describe Oakdex::Pokemon::GrowthEvents::GainedEv do
  let(:pokemon) { double(:pokemon, name: 'Beauty') }
  let(:options) { { stat: 'atk', value: 2 } }
  subject { described_class.new(pokemon, options) }

  describe '#message' do
    it { expect(subject.message)
      .to eq('Beauty got stronger in atk.') }
  end

  describe '#execute' do
    it 'adds ev for pokemon' do
      expect(pokemon).to receive(:add_ev).with('atk', 2)
      expect(pokemon).to receive(:remove_growth_event)
      subject.execute
    end
  end
end
