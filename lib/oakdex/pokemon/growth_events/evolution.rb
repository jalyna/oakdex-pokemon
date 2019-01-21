require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When pokemon could learn move
    class Evolution < Base
      def message
        "#{@pokemon.name} wants to envolve to #{@options[:evolution]}."
      end

      def possible_actions
        %w[Continue Skip]
      end

      def execute(action)
        if action == 'Skip'
          @pokemon.add_growth_event(GrowthEvents::SkippedEvolution,
                                    after: self)
        else
          original = @pokemon.name
          @pokemon.envolve_to(@options[:evolution])
          @pokemon.add_growth_event(GrowthEvents::DidEvolution,
                                    original: original,
                                    after: self)
        end

        remove_event
      end
    end
  end
end
