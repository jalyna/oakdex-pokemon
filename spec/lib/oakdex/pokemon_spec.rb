require 'spec_helper'

describe Oakdex::Pokemon do
  let(:species) { Oakdex::Pokedex::Pokemon.find('Pikachu') }
  let(:iv) do
    {
      hp: 10,
      atk: 10,
      def: 10,
      sp_atk: 10,
      sp_def: 10,
      speed: 10
    }
  end
  let(:ev) do
    {
      hp: 10,
      atk: 10,
      def: 10,
      sp_atk: 10,
      sp_def: 10,
      speed: 10
    }
  end
  let(:move) do
    Oakdex::Pokemon::Move.new(
      Oakdex::Pokedex::Move.find('Thunder Shock'), 30, 40
    )
  end
  let(:additional_attributes) { {} }
  let(:attributes) do
    {
      exp: 100,
      gender: 'female',
      ability: Oakdex::Pokedex::Ability.find('Static'),
      nature: Oakdex::Pokedex::Nature.find('Bashful'),
      hp: 12,
      iv: iv,
      ev: ev,
      moves: [move]
    }.merge(additional_attributes)
  end
  subject { described_class.new(species, attributes) }

  describe '.create' do
    let(:species_name) { 'Bulbasaur' }
    let(:options) { { level: 10 } }
    let(:pokemon) { double(:pokemon) }
    let(:species) { double(:species) }

    before do
      allow(Oakdex::Pokedex::Pokemon).to receive(:find!)
        .with(species_name).and_return(species)
      allow(Oakdex::Pokemon::Factory).to receive(:create)
        .with(species, options).and_return(pokemon)
    end

    it 'creates pokemon with auto-generated attributes' do
      expect(described_class.create(species_name, options)).to eq(pokemon)
    end
  end

  describe '#name' do
    it { expect(subject.name).to eq('Pikachu') }
  end

  describe '#species' do
    it { expect(subject.species).to eq(species) }
  end

  describe '#moves' do
    it { expect(subject.moves).to eq([move]) }
  end

  describe '#gender' do
    it { expect(subject.gender).to eq('female') }
  end

  describe '#current_hp' do
    it { expect(subject.current_hp).to eq(12) }
  end

  describe '#level' do
    it { expect(subject.level).to eq(4) }
  end

  describe '#hp' do
    it { expect(subject.hp).to eq(17) }
  end

  describe '#atk' do
    it { expect(subject.atk).to eq(9) }
  end

  describe '#def' do
    it { expect(subject.def).to eq(7) }
  end

  describe '#sp_atk' do
    it { expect(subject.sp_atk).to eq(9) }
  end

  describe '#sp_def' do
    it { expect(subject.sp_def).to eq(8) }
  end

  describe '#speed' do
    it { expect(subject.speed).to eq(12) }
  end

  describe '#moves_with_pp' do
    it { expect(subject.moves_with_pp).to eq([move]) }

    context 'no pp' do
      let(:move) do
        Oakdex::Pokemon::Move.new(
          Oakdex::Pokedex::Move.find('Thunder Shock'), 0, 40
        )
      end

      it { expect(subject.moves_with_pp).to eq([]) }
    end
  end

  describe '#change_hp_by' do
    let(:change_by) { -2 }
    before { subject.change_hp_by(change_by) }

    it { expect(subject.current_hp).to eq(10) }

    context 'hp under 0' do
      let(:change_by) { -30 }
      it { expect(subject.current_hp).to eq(0) }
    end

    context 'positive' do
      let(:change_by) { 2 }
      it { expect(subject.current_hp).to eq(14) }
    end

    context 'more than max' do
      let(:change_by) { 200 }
      it { expect(subject.current_hp).to eq(17) }
    end
  end

  describe '#change_pp_by' do
    let(:change_by) { -1 }
    let(:move_name) { 'Thunder Shock' }
    before { subject.change_pp_by(move_name, change_by) }

    it { expect(move.pp).to eq(29) }

    context 'pp under 0' do
      let(:change_by) { -40 }
      it { expect(move.pp).to eq(0) }
    end

    context 'positive' do
      let(:change_by) { 1 }
      it { expect(move.pp).to eq(31) }
    end

    context 'more than max' do
      let(:change_by) { 200 }
      it { expect(move.pp).to eq(40) }
    end

    context 'unknown move' do
      let(:move_name) { 'Struggle' }
      it { expect(move.pp).to eq(30) }
    end
  end

  %i[types].each do |field|
    describe "##{field}" do
      it {
        expect(subject.public_send(field))
        .to eq(species.public_send(field))
      }
    end
  end

  describe '#wild?' do
    it { expect(subject).not_to be_wild }

    context 'wild' do
      let(:additional_attributes) { { wild: true } }
      it { expect(subject).to be_wild }
    end
  end

  describe '#original_trainer' do
    it { expect(subject.original_trainer).to be_nil }

    context 'original trainer given' do
      let(:additional_attributes) { { original_trainer: 'Name of Trainer' } }
      it { expect(subject.original_trainer).to eq('Name of Trainer') }
    end
  end

  describe '#traded?' do
    it { expect(subject).not_to be_traded }

    context 'trainer given' do
      let!(:trainer) { double(:trainer, name: 'Awesome Trainer') }
      before { subject.trainer = trainer }
      it { expect(subject).not_to be_traded }

      context 'original trainer given' do
        let(:additional_attributes) { { original_trainer: 'Name of Trainer' } }
        it { expect(subject).to be_traded }

        context 'ot is same as trainer' do
          let(:additional_attributes) { { original_trainer: 'Awesome Trainer' } }
          it { expect(subject).not_to be_traded }
        end
      end
    end
  end

  describe '#item_id' do
    it { expect(subject.item_id).to be_nil }

    context 'item given' do
      let(:additional_attributes) { { item_id: 'Name of Item' } }
      it { expect(subject.item_id).to eq('Name of Item') }
    end
  end

  describe '#amie' do
    it { expect(subject.amie).to eq({
      affection: 0,
      fullness: 0,
      enjoyment: 0
    }) }

    context 'amie given' do
      let(:additional_attributes) { { amie: {
        affection: 1,
        fullness: 2,
        enjoyment: 3
      } } }
      it { expect(subject.amie).to eq({
        affection: 1,
        fullness: 2,
        enjoyment: 3
      }) }
    end
  end

  describe '#amie_level' do
    it { expect(subject.amie_level(:affection)).to eq(0) }

    context 'amie given' do
      let(:additional_attributes) { { amie: {
        affection: 201
      } } }
      it { expect(subject.amie_level(:affection)).to eq(4) }
    end
  end
end
