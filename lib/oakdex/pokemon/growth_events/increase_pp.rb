require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When pokemon increases pp for a move
    class IncreasePp < Base
      def message
        "Please choose a move of #{@pokemon.name} that should increase its PP."
      end

      def possible_actions
        @options[:moves].keys
      end

      def execute(action)
        @pokemon.add_growth_event(GrowthEvents::IncreaseMovePp,
                                  move_id: action,
                                  change_by: @options[:moves][action])
        remove_event
      end
    end
  end
end
