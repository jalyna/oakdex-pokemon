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
      ability_id: 'Static',
      nature_id: 'Bashful',
      hp: 12,
      iv: iv,
      ev: ev,
      moves: [move],
      friendship: 70
    }.merge(additional_attributes)
  end
  subject { described_class.new(species.names['en'], attributes) }

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

  describe '#inspect' do
    it 'does not include pokedex data' do
      expect(subject.inspect).not_to include('"catch_rate"=>')
      expect(subject.inspect).not_to include('"accuracy"=>')
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

  describe '#friendship' do
    it { expect(subject.friendship).to eq(70) }
  end

  describe '#current_hp' do
    it { expect(subject.current_hp).to eq(12) }
  end

  describe '#fainted?' do
    it { expect(subject).not_to be_fainted }
    context 'no hp left' do
      let(:additional_attributes) { { hp: 0 } }
      it { expect(subject).to be_fainted }
    end
  end

  describe '#level' do
    it { expect(subject.level).to eq(4) }
  end

  describe '#exp' do
    it { expect(subject.exp).to eq(100) }
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

  describe '#primary_status_condition' do
    before do
      subject.primary_status_condition = 'sleep'
    end
    it { expect(subject.primary_status_condition).to eq('sleep') }
  end

  describe '#add_exp' do
    it 'increases exp' do
      subject.add_exp(12)
      expect(subject.exp).to eq(112)
    end
  end

  describe '#learn_new_move' do
    it 'adds new move' do
      expect(subject.moves.last.name).not_to eq('Tackle')
      expect(subject.moves.size).to eq(1)
      subject.learn_new_move('Tackle')
      expect(subject.moves.last.name).to eq('Tackle')
      expect(subject.moves.size).to eq(2)
    end

    it 'forgets existing move' do
      expect(subject.moves.last.name).to eq('Thunder Shock')
      expect(subject.moves.size).to eq(1)
      subject.learn_new_move('Tackle', 'Thunder Shock')
      expect(subject.moves.last.name).to eq('Tackle')
      expect(subject.moves.size).to eq(1)
    end
  end

  describe '#gain_exp' do
    it 'creates growth event' do
      expect(subject).to receive(:add_growth_event)
        .with(Oakdex::Pokemon::GrowthEvents::GainedExp, gained_exp: 120)
      subject.gain_exp(120)
    end
  end

  describe '#increment_level' do
    it 'calls gain_exp' do
      expect(subject).to receive(:gain_exp).with(25)
      subject.increment_level
    end
  end

  describe '#gain_exp_from_battle' do
    let(:fainted) { double(:fainted) }
    it 'calls gain_exp' do
      expect(Oakdex::Pokemon::ExperienceGainCalculator).to receive(:calculate)
        .with(fainted, subject, flat: true)
        .and_return(25)
      expect(subject).to receive(:gain_exp).with(25)
      subject.gain_exp_from_battle(fainted, flat: true)
    end
  end

  describe '#envolve_to' do
    let(:new_pokemon) { double(:new_pokemon) }
    it 'changes species and hp' do
      allow(Oakdex::Pokedex::Pokemon).to receive(:find!)
        .with('NewPokemon').and_return(new_pokemon)
      allow(subject).to receive(:hp).and_return(10, 12)
      expect(subject).to receive(:change_hp_by).with(2)
      subject.envolve_to('NewPokemon')
      expect(subject.species).to eq(new_pokemon)
    end
  end

  describe '#add_growth_event' do
    let(:growth_event) { double(:growth_event) }
    let(:growth_event2) { double(:growth_event) }
    let(:growth_event3) { double(:growth_event) }
    let(:klass) { double(:klass) }
    let(:options) { { option1: 'value' } }

    it 'adds growth event' do
      expect(klass).to receive(:new).with(subject, options)
        .and_return(growth_event)
      subject.add_growth_event(klass, options)
      expect(subject).to be_growth_event
      expect(subject.growth_event).to eq(growth_event)
    end

    it 'adds growth event after other' do
      expect(klass).to receive(:new).with(subject, options)
        .and_return(growth_event)
      subject.add_growth_event(klass, options)
      expect(klass).to receive(:new).with(subject, option2: 'value')
        .and_return(growth_event2)
      subject.add_growth_event(klass, option2: 'value')
      expect(klass).to receive(:new).with(subject, option3: 'value')
        .and_return(growth_event3)
      subject.add_growth_event(klass, option3: 'value', after: growth_event)
      expect(subject.growth_event).to eq(growth_event)
      subject.remove_growth_event
      expect(subject.growth_event).to eq(growth_event3)
    end
  end

  describe '#growth_event?' do
    it { expect(subject).not_to be_growth_event }
  end

  describe '#growth_event' do
    it { expect(subject.growth_event).to be_nil }
  end

  describe 'growing integration' do
    it 'learns new moves' do
      pikachu = described_class.create('Pikachu', level: 12)
      pikachu.gain_exp(20_100)
      while pikachu.growth_event? do
        e = pikachu.growth_event
        if e.read_only?
          puts e.message
          e.execute
        else
          puts e.message
          puts e.possible_actions.inspect
          a = e.possible_actions.sample
          puts "Execute #{a}"
          e.execute(a)
        end
      end
      expect(pikachu.level).to eq(27)
    end

    it 'envolves' do
      charmander = described_class.create('Charmander', level: 15)
      charmander.increment_level
      while charmander.growth_event? do
        e = charmander.growth_event
        if e.read_only?
          puts e.message
          e.execute
        else
          puts e.message
          puts e.possible_actions.inspect
          a = e.possible_actions.first
          puts "Execute #{a}"
          e.execute(a)
        end
      end
      expect(charmander.level).to eq(16)
      expect(charmander.name).to eq('Charmeleon')
    end
  end
end
