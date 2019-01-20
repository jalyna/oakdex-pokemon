require 'spec_helper'

describe Oakdex::Pokemon::Move do
  let(:move_type) { Oakdex::Pokedex::Move.find('Thunder Shock') }
  subject { described_class.new(move_type, 30, 30) }

  describe '.create' do
    it 'creates move by given id' do
      move = described_class.create('Struggle')
      expect(move.name).to eq('Struggle')
      expect(move).to be_a(described_class)
    end
  end

  describe '#name' do
    it { expect(subject.name).to eq('Thunder Shock') }
  end

  describe '#pp' do
    it { expect(subject.pp).to eq(30) }
  end

  describe '#type_id' do
    it { expect(subject.type_id).to eq('Electric') }
  end

  describe '#type' do
    it { expect(subject.type).to eq(Oakdex::Pokedex::Type.find('Electric')) }
  end

  %i[target priority accuracy category power stat_modifiers in_battle_properties].each do |attr|
    describe "##{attr}" do
      it {
        expect(subject.public_send(attr))
        .to eq(move_type.public_send(attr))
      }
    end
  end
end
