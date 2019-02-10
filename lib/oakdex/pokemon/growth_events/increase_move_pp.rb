require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When picked move for increasing pp
    class IncreaseMovePp < Base
      def message
        "#{@pokemon.name} increased PP for #{@options[:move_id]}."
      end

      def execute
        move = @pokemon.moves.find { |m| m.name == @options[:move_id] }
        move.add_pp(@options[:change_by])
        remove_event
      end
    end
  end
end
