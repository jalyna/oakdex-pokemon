module Oakdex
  class Pokemon
    # Represents Item usage
    class UseItemService
      def initialize(pokemon, item_id, options = {})
        @pokemon = pokemon
        @item = Oakdex::Pokedex::Item.find!(item_id)
        @options = options
      end

      def usable?
        !evolution.nil?
      end

      def use
        return unless usable?
        @pokemon.add_growth_event(GrowthEvents::Evolution,
                                  evolution: evolution)
        true
      end

      private

      def evolution
        EvolutionMatcher.new(@pokemon, 'item', item_id: @item.name).evolution
      end
    end
  end
end
