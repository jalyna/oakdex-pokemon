require 'forwardable'
require 'oakdex/pokedex'

require 'oakdex/pokemon/stat'
require 'oakdex/pokemon/move'
require 'oakdex/pokemon/factory'
require 'oakdex/pokemon/experience_gain_calculator'

module Oakdex
  # Represents detailed pokemon instance
  class Pokemon
    extend Forwardable

    BATTLE_STATS = %i[hp atk def sp_atk sp_def speed]

    def_delegators :species, :types

    attr_accessor :trainer

    def self.create(species_name, options = {})
      species = Oakdex::Pokedex::Pokemon.find!(species_name)
      Factory.create(species, options)
    end

    def initialize(species_id, attributes = {})
      @species_id = species_id
      @attributes = attributes
    end

    def species
      @species ||= Oakdex::Pokedex::Pokemon.find!(@species_id)
    end

    def inspect
      "#<#{self.class.name}:#{object_id} #{@attributes.inspect}>"
    end

    def primary_status_condition
      @attributes[:primary_status_condition]
    end

    def primary_status_condition=(value)
      @attributes[:primary_status_condition] = value
    end

    def name
      species.names['en']
    end

    def gender
      @attributes[:gender]
    end

    def moves
      @attributes[:moves]
    end

    def current_hp
      @attributes[:hp]
    end

    def fainted?
      current_hp.zero?
    end

    def moves_with_pp
      moves.select { |m| m.pp > 0 }
    end

    def wild?
      @attributes[:wild]
    end

    def original_trainer
      @attributes[:original_trainer]
    end

    def item_id
      @attributes[:item_id]
    end

    def amie
      {
        affection: 0,
        fullness: 0,
        enjoyment: 0
      }.merge(@attributes[:amie] || {})
    end

    def amie_level(amie_stat)
      5 - [255, 150, 100, 50, 1, 0].find_index do |treshold|
        amie[amie_stat] >= treshold
      end
    end

    def traded?
      return false if trainer.nil? || original_trainer.nil?
      return false unless trainer.respond_to?(:name)
      trainer.name != original_trainer
    end

    def change_hp_by(hp_change)
      @attributes[:hp] = if hp_change < 0
                           [@attributes[:hp] + hp_change, 0].max
                         else
                           [@attributes[:hp] + hp_change, hp].min
                         end
    end

    def change_pp_by(move_name, pp_change)
      move = moves.find { |m| m.name == move_name }
      return unless move
      move.pp = if pp_change < 0
                  [move.pp + pp_change, 0].max
                else
                  [move.pp + pp_change, move.max_pp].min
                end
    end

    def exp
      @attributes[:exp]
    end

    def level
      Stat.level_by_exp(species.leveling_rate, @attributes[:exp])
    end

    BATTLE_STATS.each do |stat|
      define_method stat do
        initial_stat(stat)
      end
    end

    private

    def initial_stat(stat)
      Stat.initial_stat(stat,
                        level:      level,
                        nature:     nature,
                        iv:         @attributes[:iv],
                        ev:         @attributes[:ev],
                        base_stats: species.base_stats
                       )
    end

    def nature
      @nature ||= Oakdex::Pokedex::Nature.find!(@attributes[:nature_id])
    end
  end
end
