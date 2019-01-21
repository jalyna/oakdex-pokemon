require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When pokemon gains exp
    class GainedExp < Base
      def message
        "#{@pokemon.name} gained #{@options[:gained_exp]} EXP."
      end

      def execute
        level_before = @pokemon.level
        @pokemon.add_exp(@options[:gained_exp])
        last_evt = self
        ((level_before + 1)...(@pokemon.level + 1)).to_a.each do |new_level|
          last_evt = @pokemon.add_growth_event(GrowthEvents::LevelUp,
                                               new_level: new_level,
                                               after: last_evt)
        end
        remove_event
      end
    end
  end
end
