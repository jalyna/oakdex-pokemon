require 'spec_helper'

describe Oakdex::Pokemon::GrowthEvents::SkippedEvolution do
  let(:pokemon) { double(:pokemon, name: 'Beauty') }
  subject { described_class.new(pokemon, options) }

  describe '#message' do
    it { expect(subject.message)
      .to eq('Beauty did not envolve.') }
  end
end
