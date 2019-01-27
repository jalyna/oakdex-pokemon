require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When pokemon gets status condition healed
    class RemoveStatusCondition < Base
      def message
        "#{@pokemon.name} heals #{@pokemon.primary_status_condition}."
      end

      def execute
        @pokemon.primary_status_condition = nil
        remove_event
      end
    end
  end
end
