require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When move was not learned
    class DidNotLearnMove < Base
      def message
        "#{@pokemon.name} did not learn #{@options[:move_id]}."
      end
    end
  end
end
