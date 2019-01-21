require 'spec_helper'

describe Oakdex::Pokemon::GrowthEvents::ForgotAndLearnedMove do
  let(:pokemon) { double(:pokemon, name: 'Beauty') }
  let(:options) { { move_id: 'Tackle', forgot_move_id: 'Thunder Shock' } }
  subject { described_class.new(pokemon, options) }

  describe '#message' do
    it { expect(subject.message)
      .to eq('Beauty learned Tackle and forgot Thunder Shock.') }
  end
end
