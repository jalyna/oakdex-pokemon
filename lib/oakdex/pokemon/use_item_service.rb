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
        !evolution.nil? || effect_usable?
      end

      def use
        return unless usable?
        if !evolution.nil?
          @pokemon.add_growth_event(GrowthEvents::Evolution,
                                    evolution: evolution)
        end
        execute_effects
        true
      end

      private

      def in_battle?
        @options[:in_battle]
      end

      def effect_usable?
        @item.effects.any? do |effect|
          condition_applies?(effect) && target_applies?(effect) &&
            pokemon_changes_apply?(effect)
        end
      end

      def condition_applies?(effect)
        condition = effect['condition']
        condition == 'Always' ||
            (in_battle? && condition == 'During Battle') ||
            (!in_battle? && condition == 'Outside of Battle')
      end

      def target_applies?(effect)
        target = effect['target']
        ['Single Pokemon', 'Single Pokemon > Single Move',
          'Single Pokemon > All Moves', 'Team'].include?(target)
      end

      def pokemon_changes_apply?(effect)
        pokemon_changes = effect['pokemon_changes'] || []
        return true if pokemon_changes.empty?
        pokemon_changes.any? do |change|
          pokemon_change_applies?(change)
        end
      end

      def pokemon_change_applies?(change)
        !pokemon_field_max?(change) &&
          (!@pokemon.fainted? || (@pokemon.fainted? && change['revive']))
      end

      def pokemon_field_max?(change)
        case change['field']
        when 'current_hp' then @pokemon.current_hp >= @pokemon.hp
        when 'status_condition' then !change['conditions']
          .include?(@pokemon.primary_status_condition)
        end
      end

      def execute_effects
        @item.effects.each do |effect|
          execute_pokemon_changes(effect)
        end
      end

      def execute_pokemon_changes(effect)
        (effect['pokemon_changes'] || []).each do |change|
          if pokemon_change_applies?(change)
            execute_pokemon_change(change)
          end
        end
      end

      def execute_pokemon_change(change)
        case change['field']
        when 'current_hp' then execute_current_hp_change(change)
        when 'status_condition' then execute_remove_status_condition(change)
        end
      end

      def execute_remove_status_condition(_change)
        @pokemon.add_growth_event(GrowthEvents::RemoveStatusCondition)
      end

      def execute_current_hp_change(change)
        change_by = change['change_by']
        if change['change_by_percent']
          change_by = percent_calculation(:hp, change['change_by_percent'])
        end
        if change['revive']
          @pokemon.add_growth_event(GrowthEvents::Revive, hp: change_by)
        else
          @pokemon.add_growth_event(GrowthEvents::AddHp, hp: change_by)
        end
      end

      def percent_calculation(field, percent)
        (@pokemon.public_send(field).to_f * (percent.to_f / 100)).to_i
      end

      def evolution
        EvolutionMatcher.new(@pokemon, 'item', item_id: @item.name).evolution
      end
    end
  end
end
