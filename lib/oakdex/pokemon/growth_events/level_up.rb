require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When pokemon reached the next level
    class LevelUp < Base
      def message
        "#{@pokemon.name} reached Level #{@options[:new_level]}."
      end

      def execute
        last_evt = self
        available_moves.each do |move_id|
          last_evt = @pokemon.add_growth_event(GrowthEvents::LearnMove,
                                               move_id: move_id,
                                               after: last_evt)
        end
        remove_event
      end

      private

      def available_moves
        @pokemon.species.learnset.map do |m|
          m['move'] if m['level'] && m['level'] == @options[:new_level]
        end.compact
      end
    end
  end
end
