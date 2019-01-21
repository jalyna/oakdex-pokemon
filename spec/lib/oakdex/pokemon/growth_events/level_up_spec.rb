require 'spec_helper'

describe Oakdex::Pokemon::GrowthEvents::LevelUp do
  let(:pokemon) { double(:pokemon, name: 'Beauty') }
  let(:options) { { new_level: 9 } }
  subject { described_class.new(pokemon, options) }

  describe '#message' do
    it { expect(subject.message)
      .to eq('Beauty reached Level 9.') }
  end

  describe '#execute' do
    pending
  end
end
