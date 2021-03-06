require 'spec_helper'

describe Oakdex::Pokemon do
  describe '.create' do
    let(:species_name) { 'Bulbasaur' }
    let(:options) do
      { 
        level: 10,
        wild: true,
        original_trainer: 'Name of Trainer',
        item_id: 'Name of Item',
        primary_status_condition: 'fire',
        amie: {
          affection: 1,
          fullness: 2,
          enjoyment: 3
        }
      }
    end
    let(:exp) { 50 }
    let(:hp) { double(:hp) }
    let(:pokemon) { double(:pokemon) }
    let(:ability_name) { 'Soundproof' }
    let(:ability) { double(:ability, names: { 'en' => ability_name }) }
    let(:nature) { double(:nature, names: { 'en' => 'Careful' }) }
    let(:gender) { 'female' }
    let(:move_type) { double(:move_type, pp: 44) }
    let(:move) { double(:move) }
    let(:species) do
      double(:species,
             names: { 'en' => 'My Species' },
             leveling_rate: 'leveling_rate',
             base_friendship: 70,
             gender_ratios: {
               'male' => 25.5,
               'female' => 74.5
             },
             abilities: [
               {
                 'name' => ability_name
               },
               {
                 'name' => 'Bla',
                 'hidden' => true
               },
               {
                 'name' => 'Blub',
                 'mega' => true
               }
             ],
             base_stats: {
               'hp' => 123
             },
             learnset: [
               {
                 'move' => 'Move1',
                 'level' => 3
               },
               {
                 'move' => 'Move2',
                 'level' => 50
               },
               {
                 'move' => 'Move3'
               }
             ]
            )
    end
    let(:ev) do
      {
        hp: 0,
        atk: 0,
        def: 0,
        sp_atk: 0,
        sp_def: 0,
        speed: 0
      }
    end
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
    let(:attributes) do
      {
        exp: exp,
        gender: gender,
        ability_id: ability_name,
        nature_id: 'Careful',
        hp: hp,
        iv: iv,
        ev: ev,
        moves: [move],
        wild: true,
        original_trainer: 'Name of Trainer',
        item_id: 'Name of Item',
        primary_status_condition: 'fire',
        friendship: 70,
        amie: {
          affection: 1,
          fullness: 2,
          enjoyment: 3
        }
      }
    end

    before do
      allow(Oakdex::Pokedex::Pokemon).to receive(:find!)
        .with(species_name).and_return(species)
      allow(Oakdex::Pokedex::Move).to receive(:find!)
        .with('Move1').and_return(move_type)
      allow(Oakdex::Pokemon::Move).to receive(:new)
        .with(move_type, move_type.pp, move_type.pp).and_return(move)
      allow(Oakdex::Pokemon::Stat).to receive(:exp_by_level)
        .with(species.leveling_rate, options[:level]).and_return(exp)
      allow(Oakdex::Pokedex::Nature).to receive(:all)
        .and_return('Careful' => nature)
      allow(Oakdex::Pokedex::Nature).to receive(:find!).with('Careful')
        .and_return(nature)
      allow_any_instance_of(Oakdex::Pokemon::Factory)
        .to receive(:rand).with(1..1000).and_return(500)
      allow_any_instance_of(Oakdex::Pokemon::Factory)
        .to receive(:rand).with(0..31).and_return(10)
      allow(Oakdex::Pokemon::Stat).to receive(:level_by_exp)
        .with(species.leveling_rate, exp).and_return(options[:level])
      allow(Oakdex::Pokemon::Stat).to receive(:initial_stat)
        .with(:hp,
              level: options[:level],
              iv: iv,
              ev: ev,
              base_stats: species.base_stats,
              nature: nature
             )
        .and_return(hp)
    end

    it 'creates pokemon with auto-generated attributes' do
      expect(described_class).to receive(:new).with(
        'My Species',
        attributes
      ).and_return(pokemon)
      expect(described_class.create(species_name, options)).to eq(pokemon)
    end

    context 'additional moves given' do
      let(:new_options) do
        options.merge({
          additional_moves: %w[
            MyMove0
            MyMove1
            MyMove2
            MyMove3
          ]
        })
      end
      let(:move_type2) { double(:move_type2, pp: 44) }
      let(:move2) { double(:move2) }
      let(:move_type3) { double(:move_type3, pp: 43) }
      let(:move3) { double(:move3) }
      let(:move_type4) { double(:move_type4, pp: 42) }
      let(:move4) { double(:move4) }
      let(:move_type5) { double(:move_type5, pp: 41) }
      let(:move5) { double(:move5) }

      before do
        allow(Oakdex::Pokedex::Move).to receive(:find!)
          .with('MyMove0').and_return(move_type2)
        allow(Oakdex::Pokemon::Move).to receive(:new)
          .with(move_type2, move_type2.pp, move_type2.pp).and_return(move2)

        allow(Oakdex::Pokedex::Move).to receive(:find!)
          .with('MyMove1').and_return(move_type3)
        allow(Oakdex::Pokemon::Move).to receive(:new)
          .with(move_type3, move_type3.pp, move_type3.pp).and_return(move3)

        allow(Oakdex::Pokedex::Move).to receive(:find!)
          .with('MyMove2').and_return(move_type4)
        allow(Oakdex::Pokemon::Move).to receive(:new)
          .with(move_type4, move_type4.pp, move_type4.pp).and_return(move4)

        allow(Oakdex::Pokedex::Move).to receive(:find!)
          .with('MyMove3').and_return(move_type5)
        allow(Oakdex::Pokemon::Move).to receive(:new)
          .with(move_type5, move_type5.pp, move_type5.pp).and_return(move5)
      end

      let(:new_attributes) do
        attributes.merge({
          moves: [move, move2, move3, move4]
        })
      end

      it 'creates pokemon with auto-generated attributes plus additional moves' do
        expect(described_class).to receive(:new).with(
          'My Species',
          new_attributes
        ).and_return(pokemon)
        expect(described_class.create(species_name, new_options)).to eq(pokemon)
      end
    end

    context 'data given' do
      let(:iv) do
        {
          hp: 10,
          atk: 10,
          def: 10,
          sp_atk: 12,
          sp_def: 30,
          speed: 10
        }
      end
      let(:ev) do
        {
          hp: 33,
          atk: 34,
          def: 0,
          sp_atk: 120,
          sp_def: 0,
          speed: 0
        }
      end
      let(:gender) { 'male' }
      let(:hp) { 17 }

      let(:new_options) do
        options.merge({
          exp: exp,
          gender: 'male',
          ability: 'Something',
          nature: 'Careful',
          hp: hp,
          iv: iv,
          ev: ev,
          moves: [
            ['MyMove', 20, 30]
          ]
        })
      end

      before do
        allow(Oakdex::Pokedex::Move).to receive(:find!)
          .with('MyMove').and_return(move_type)
        allow(Oakdex::Pokemon::Move).to receive(:new)
          .with(move_type, 20, 30).and_return(move)
      end

      it 'creates pokemon by given attributes' do
        expect(described_class).to receive(:new).with(
          'My Species',
          attributes
        ).and_return(pokemon)
        expect(described_class.create(species_name, new_options)).to eq(pokemon)
      end
    end
  end
end
