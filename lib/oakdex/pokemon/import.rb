require 'json-schema'
require 'json'
require 'oakdex/pokemon/invalid_pokemon'

module Oakdex
  class Pokemon
    # Imports and validates pokemon
    class Import
      def self.schema
        schema_path = File.join Oakdex::Pokemon.root, 'lib', 'oakdex', 'pokemon', 'schema.json'
        @schema ||= File.read(File.expand_path(schema_path))
      end

      def initialize(data)
        @data = data.is_a?(Hash) ? data : JSON.parse(data)
      end

      def import!
        JSON::Validator.validate!(self.class.schema, @data)
        pok = Oakdex::Pokemon.new(@data['species_id'], attributes)
        apply_growth_events(pok)
        pok
      rescue JSON::Schema::ValidationError => e
        raise Oakdex::Pokemon::InvalidPokemon, e.message
      rescue Oakdex::Pokedex::NotFound => e
        raise Oakdex::Pokemon::InvalidPokemon, e.message
      end

      private

      def attributes
        @data.map do |k, v|
          next if k == 'species_id' || k == 'growth_events'
          if k == 'moves'
            [:moves, moves]
          elsif v.is_a?(Hash)
            [k.to_sym, v.map { |k2, v2| [k2.to_sym, v2] }.to_h]
          else
            [k.to_sym, v]
          end
        end.compact.to_h
      end

      def moves
        (@data['moves'] || []).map do |move_data|
          move_type = Oakdex::Pokedex::Move.find!(move_data['move_id'])
          Move.new(move_type, move_data['pp'], move_data['max_pp'])
        end
      end

      def apply_growth_events(pok)
        (@data['growth_events'] || []).each do |growth_event_data|
          klass = Object.const_get(growth_event_data['name'])
          pok.add_growth_event(klass, growth_event_data['options'].map do |k, v|
            [k.to_sym, v]
          end.to_h)
        end
      end
    end
  end
end
