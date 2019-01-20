require 'forwardable'
require 'oakdex/pokedex'

require 'oakdex/pokemon/stat'
require 'oakdex/pokemon/move'
require 'oakdex/pokemon/factory'

module Oakdex
  # Represents detailed pokemon instance
  class Pokemon
    extend Forwardable

    BATTLE_STATS = %i[hp atk def sp_atk sp_def speed]

    def_delegators :@species, :types

    attr_accessor :trainer
    attr_reader :species

    def self.create(species_name, options = {})
      species = Oakdex::Pokedex::Pokemon.find!(species_name)
      Factory.create(species, options)
    end

    def initialize(species, attributes = {})
      @species = species
      @attributes = attributes
    end

    def name
      @species.names['en']
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

    def level
      Stat.level_by_exp(@species.leveling_rate, @attributes[:exp])
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
                        nature:     @attributes[:nature],
                        iv:         @attributes[:iv],
                        ev:         @attributes[:ev],
                        base_stats: @species.base_stats
                       )
    end
  end
end
