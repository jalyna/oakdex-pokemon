require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When pokemon receives HP and revives
    class Revive < AddHp
      def message
        "#{@pokemon.name} revives and heals by #{real_hp}HP."
      end
    end
  end
end
