require 'spec_helper'

describe Oakdex::Pokemon::GrowthEvents::DidNotLearnMove do
  let(:pokemon) { double(:pokemon, name: 'Beauty') }
  let(:options) { { move_id: 'Tackle' } }
  subject { described_class.new(pokemon, options) }

  describe '#message' do
    it { expect(subject.message)
      .to eq('Beauty did not learn Tackle.') }
  end
end
