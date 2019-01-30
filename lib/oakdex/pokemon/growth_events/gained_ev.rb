require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When pokemon gains ev
    class GainedEv < Base
      def message
        "#{@pokemon.name} got stronger in #{@options[:stat]}."
      end

      def execute
        @pokemon.add_ev(@options[:stat], @options[:value])
        remove_event
      end
    end
  end
end
