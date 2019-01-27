require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When pokemon received HP
    class AddHp < Base
      def message
        "#{@pokemon.name} heals by #{real_hp}HP."
      end

      def execute
        @pokemon.change_hp_by(@options[:hp])
        remove_event
      end

      private

      def real_hp
        max_add = @pokemon.hp - @pokemon.current_hp
        [max_add, @options[:hp]].min
      end
    end
  end
end
