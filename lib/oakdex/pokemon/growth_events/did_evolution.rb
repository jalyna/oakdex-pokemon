require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When pokemon envolved successfully
    class DidEvolution < Base
      def message
        "#{@options[:original]} envolved into #{@pokemon.name}."
      end
    end
  end
end
