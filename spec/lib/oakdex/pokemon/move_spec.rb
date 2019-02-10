require 'spec_helper'

describe Oakdex::Pokemon::Move do
  let(:max_pp) { 30 }
  let(:pp) { 30 }
  let(:move_type) { Oakdex::Pokedex::Move.find('Thunder Shock') }
  subject { described_class.new(move_type, pp, max_pp) }

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

  describe '#pp_max?' do
    it { expect(subject).to be_pp_max }

    context 'pp is not at max' do
      let(:pp) { 12 }
      it { expect(subject).not_to be_pp_max }
    end
  end

  describe '#add_pp' do
    let(:pp) { 20 }

    it 'increases pp until max pp' do
      subject.add_pp(20)
      expect(subject.pp).to eq(30)
    end
  end

  describe '#max_pp_at_max?' do
    it { expect(subject).not_to be_max_pp_at_max }

    context 'pp is max at 48' do
      let(:max_pp) { 48 }
      it { expect(subject).to be_max_pp_at_max }
    end
  end

  describe '#add_max_pp' do
    it 'increases max pp and pp' do
      subject.add_max_pp(3)
      expect(subject.max_pp).to eq(33)
      expect(subject.pp).to eq(33)
    end

    context 'pp is nearly reached' do
      let(:max_pp) { 45 }

      it 'increases max pp and pp until maximum' do
        subject.add_max_pp(20)
        expect(subject.max_pp).to eq(48)
        expect(subject.pp).to eq(33)
      end
    end
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
