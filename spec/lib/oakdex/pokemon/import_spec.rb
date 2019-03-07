require 'spec_helper'

describe Oakdex::Pokemon::Import do
  let(:json) { { 'species_id' => 'Pikachu' } }
  let(:attributes) { {} }
  let(:pokemon) { double(:pokemon) }
  let(:schema) do
    File.read(File.expand_path('./lib/oakdex/pokemon/schema.json'))
  end
  subject { described_class.new(json) }

  describe '#import!' do
    before do
      allow(Oakdex::Pokemon).to receive(:new)
        .with('Pikachu', attributes).and_return(pokemon)
    end

    it 'validates with schema' do
      expect(JSON::Validator).to receive(:validate!)
        .with(schema, json)
        .and_return(true)
      expect(subject.import!).to eq(pokemon)
    end
  end

  describe 'forth and back' do
    let(:move) do
      ['Swords Dance', 12, 30]
    end
    it 'import and exports' do
      pok = Oakdex::Pokemon.create('Mew', level: 32, moves: [move])
      importer = described_class.new(pok.to_json)
      expect(importer.import!.to_json).to eq(pok.to_json)
      expect(importer.import!.moves.first.name).to eq(pok.moves.first.name)
      expect(importer.import!.atk).to eq(pok.atk)
    end

    it 'imports and exports with growth events' do
      pok = Oakdex::Pokemon.create('Mew', level: 32, moves: [move])
      pok.increment_level
      importer = described_class.new(pok.to_json)
      expect(importer.import!.to_json).to eq(pok.to_json)
      expect(importer.import!.moves.first.name).to eq(pok.moves.first.name)
      expect(importer.import!.growth_event.message).to eq(pok.growth_event.message)
    end

    it 'raises error when it has invalid json' do
      pok = Oakdex::Pokemon.create('Mew', level: 32, moves: [move])
      json = JSON.parse(pok.to_json)
      json['primary_status_condition'] = 'foobar'
      importer = described_class.new(JSON.dump(json))
      expect { importer.import! }.to raise_error(Oakdex::Pokemon::InvalidPokemon,
        "The property '#/primary_status_condition' value \"foobar\" did not match one of the following values: poison, bad_poison, paralysis, sleep, freeze, burn, null")
    end

    it 'raises error when relation was not found' do
      pok = Oakdex::Pokemon.create('Mew', level: 32, moves: [move])
      json = JSON.parse(pok.to_json)
      json['species_id'] = 'foobar'
      importer = described_class.new(JSON.dump(json))
      expect { importer.import! }.to raise_error(Oakdex::Pokemon::InvalidPokemon,
        "foobar (pokemon) could not be found")
    end
  end
end
