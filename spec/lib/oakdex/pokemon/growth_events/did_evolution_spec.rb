require 'spec_helper'

describe Oakdex::Pokemon::GrowthEvents::DidEvolution do
  let(:pokemon) { double(:pokemon, name: 'Beauty') }
  let(:options) { { original: 'Original' } }
  subject { described_class.new(pokemon, options) }

  describe '#message' do
    it { expect(subject.message)
      .to eq('Original envolved into Beauty.') }
  end
end
