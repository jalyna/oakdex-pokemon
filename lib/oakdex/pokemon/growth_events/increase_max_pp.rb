require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When pokemon increases max pp for a move
    class IncreaseMaxPp < Base
      def message
        "Please choose a move of #{@pokemon.name} that should increase its Max PP."
      end

      def possible_actions
        @options[:moves].keys
      end

      def execute(action)
        @pokemon.add_growth_event(GrowthEvents::IncreaseMoveMaxPp,
                                  move_id: action,
                                  change_by: @options[:moves][action])
        remove_event
      end
    end
  end
end
