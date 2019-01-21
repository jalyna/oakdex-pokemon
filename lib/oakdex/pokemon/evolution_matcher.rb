module Oakdex
  class Pokemon
    # Calculates if Pokemon can envolve and to which
    # item, move_learned, trade, level_up are possible triggers
    class EvolutionMatcher
      TRIGGERS = %w[item trade level level_up move_learned happiness]

      def initialize(pokemon, trigger, options = {})
        @pokemon = pokemon
        @trigger = trigger
        @options = options
      end

      def evolution
        evolutions.sample
      end

      private

      def evolutions
        available_evolutions.map do |e|
          e['to'] if trigger_for(e) == @trigger && valid_evolution?(e)
        end.compact
      end

      def available_evolutions
        @pokemon.species.evolutions
      end

      def trigger_for(evolution)
        original_trigger = TRIGGERS.find do |t|
          evolution[t]
        end
        return 'level_up' if %w[level happiness].include?(original_trigger)
        original_trigger
      end

      def valid_evolution?(e)
        hold_item_match?(e) && item_match?(e) && happiness_match?(e) &&
          level_match?(e) && move_learned_match?(e) && conditions_match?(e)
      end

      def hold_item_match?(e)
        !e['hold_item'] || e['hold_item'] == @pokemon.item_id
      end

      def item_match?(e)
        !e['item'] || e['item'] == @options[:item_id]
      end

      def happiness_match?(e)
        !e['happiness'] || @pokemon.friendship >= 220
      end

      def level_match?(e)
        !e['level'] || @pokemon.level >= e['level']
      end

      def move_learned_match?(e)
        !e['move_learned'] || @pokemon.moves.map(&:name)
          .include?(e['move_learned'])
      end

      def conditions_match?(e)
        (e['conditions'] || []).all? do |condition|
          method_name = condition.downcase.tr(' é', '_e')
            .gsub('>', 'bigger_than')
            .gsub('=', 'equal')
            .gsub('<', 'lower_than')
          if respond_to?("#{method_name}?", true)
            send("#{method_name}?")
          else
            false
          end
        end
      end

      def female?
        @pokemon.gender == 'female'
      end

      def male?
        @pokemon.gender == 'male'
      end

      def attack_bigger_than_defense?
        @pokemon.atk > @pokemon.def
      end

      def attack_equal_defense?
        @pokemon.atk == @pokemon.def
      end

      def defense_bigger_than_defense?
        @pokemon.def > @pokemon.atk
      end

      def random?
        true
      end
    end
  end
end
