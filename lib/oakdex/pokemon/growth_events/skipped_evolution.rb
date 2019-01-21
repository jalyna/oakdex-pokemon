require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When pokemon did not evolve
    class SkippedEvolution < Base
      def message
        "#{@pokemon.name} did not envolve."
      end
    end
  end
end
