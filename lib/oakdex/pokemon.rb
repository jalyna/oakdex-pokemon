require 'forwardable'
require 'json'
require 'oakdex/pokedex'

require 'oakdex/pokemon/stat'
require 'oakdex/pokemon/move'
require 'oakdex/pokemon/factory'
require 'oakdex/pokemon/experience_gain_calculator'
require 'oakdex/pokemon/evolution_matcher'
require 'oakdex/pokemon/use_item_service'
require 'oakdex/pokemon/growth_events'
require 'oakdex/pokemon/import'

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
      @attributes[:growth_events] ||= []
      species
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

    def friendship
      @attributes[:friendship]
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

    def add_exp(exp_to_add)
      @attributes[:exp] += exp_to_add
    end

    def add_ev(stat, ev_to_add)
      @attributes[:ev] = @attributes[:ev].map do |k, v|
        [k, k.to_s == stat ? [v + ev_to_add, 255].min : v]
      end.to_h
    end

    def ev_max?(stat)
      @attributes[:ev][stat].to_i >= 255
    end

    def learn_new_move(move_id, replaced_move_id = nil)
      new_move = Move.create(move_id)
      if replaced_move_id.nil?
        @attributes[:moves] << new_move
      else
        index = @attributes[:moves]
          .find_index { |m| m.name == replaced_move_id }
        @attributes[:moves][index] = new_move if index
      end
    end

    def gain_exp(gained_exp)
      add_growth_event(GrowthEvents::GainedExp, gained_exp: gained_exp)
    end

    def trade_to(trainer)
      self.trainer = trainer
      available_evolution = EvolutionMatcher.new(self, 'trade').evolution

      add_growth_event(GrowthEvents::Evolution,
                       evolution: available_evolution) if available_evolution
    end

    def usable_item?(item_id, options = {})
      service = UseItemService.new(self, item_id, options)
      service.usable?
    end

    def use_item(item_id, options = {})
      service = UseItemService.new(self, item_id, options)
      service.use
    end

    def increment_level
      gained_exp = exp_next_level - @attributes[:exp]
      gain_exp(gained_exp)
    end

    def grow_from_battle(fainted, options = {})
      exp = ExperienceGainCalculator.calculate(fainted, self, options)
      gain_exp(exp)
      gain_ev_from_battle(fainted) unless options[:using_exp_share]
    end

    def growth_event?
      !@attributes[:growth_events].empty?
    end

    def growth_event
      @attributes[:growth_events].first
    end

    def remove_growth_event
      @attributes[:growth_events].shift
    end

    def add_growth_event(klass, options = {})
      evt = klass.new(self, options.select { |k, _| k != :after })
      if options[:after]
        index = @attributes[:growth_events].index(options[:after])
        if index.nil?
          @attributes[:growth_events] << evt
        else
          @attributes[:growth_events].insert(index + 1, evt)
        end
      else
        @attributes[:growth_events] << evt
      end

      evt
    end

    def envolve_to(species_id)
      old_max_hp = hp
      @species = nil
      @species_id = species_id
      change_hp_by(hp - old_max_hp) unless fainted?
      species
    end

    def to_json
      JSON.dump(to_h)
    end

    def self.from_json(json)
      Import.new(json).import!
    end

    private

    def to_h
      @attributes.dup.tap do |attributes|
        attributes[:species_id] = species.name
        attributes[:moves] = attributes[:moves].map(&:to_h)
        attributes[:growth_events] = attributes[:growth_events].map(&:to_h)
      end
    end

    def gain_ev_from_battle(fainted)
      fainted.species.ev_yield.each do |stat, value|
        next if value.zero?
        add_growth_event(GrowthEvents::GainedEv, stat: stat, value: value)
      end
    end

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

    def exp_next_level
      Stat.exp_by_level(species.leveling_rate, level + 1)
    end
  end
end
