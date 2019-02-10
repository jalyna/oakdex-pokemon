require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When picked move for increasing max pp
    class IncreaseMoveMaxPp < Base
      def message
        "#{@pokemon.name} increased Max PP for #{@options[:move_id]}."
      end

      def execute
        move = @pokemon.moves.find { |m| m.name == @options[:move_id] }
        move.add_max_pp(@options[:change_by])
        remove_event
      end
    end
  end
end
