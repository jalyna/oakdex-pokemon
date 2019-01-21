require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When move was learnt and other move was forgotten
    class ForgotAndLearnedMove < Base
      def message
        "#{@pokemon.name} learned #{@options[:move_id]} and forgot #{@options[:forgot_move_id]}."
      end

      def execute
        if available_evolution
          @pokemon.add_growth_event(GrowthEvents::Evolution,
                                    evolution: available_evolution,
                                    after: self)
        end
        remove_event
      end

      private

      def available_evolution
        @available_evolution ||= Oakdex::Pokemon::EvolutionMatcher
          .new(@pokemon, 'move_learned', move_id: @options[:move_id]).evolution
      end
    end
  end
end
