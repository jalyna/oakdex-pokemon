require 'spec_helper'

describe Oakdex::Pokemon::GrowthEvents::GainedExp do
  let(:pokemon) { double(:pokemon, name: 'Beauty') }
  let(:options) { { gained_exp: 129 } }
  subject { described_class.new(pokemon, options) }

  describe '#message' do
    it { expect(subject.message)
      .to eq('Beauty gained 129 EXP.') }
  end

  describe '#execute' do
    pending
  end
end
