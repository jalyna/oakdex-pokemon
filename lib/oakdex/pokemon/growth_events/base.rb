require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # Represents Base GrowthEvent
    class Base
      def initialize(pokemon, options = {})
        @pokemon = pokemon
        @options = options
      end

      def read_only?
        possible_actions.empty?
      end

      def possible_actions
        []
      end

      def message
        raise 'implement me'
      end

      def execute(_action = nil)
        remove_event
      end

      def to_h
        {
          name: self.class.name,
          options: @options
        }
      end

      private

      def remove_event
        @pokemon.remove_growth_event
      end
    end
  end
end
