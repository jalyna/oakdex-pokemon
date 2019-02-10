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
        unless evolution.nil?
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
            pokemon_changes_apply?(effect) && move_changes_apply?(effect)
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

      def move_changes_apply?(effect)
        move_changes = effect['move_changes'] || []
        return true if move_changes.empty?
        move_changes.any? do |change|
          move_change_applies?(change)
        end
      end

      def pokemon_change_applies?(change)
        !pokemon_field_max?(change) &&
          (independent_fainted?(change) ||
            !@pokemon.fainted? ||
            (@pokemon.fainted? && change['revive']))
      end

      def move_change_applies?(change)
        !move_field_max?(change)
      end

      def move_field_max?(change)
        case change['field']
        when 'max_pp' then @pokemon.moves.all?(&:max_pp_at_max?)
        end
      end

      def pokemon_field_max?(change)
        case change['field']
        when 'current_hp' then @pokemon.current_hp >= @pokemon.hp
        when 'level' then @pokemon.level >= 100
        when /^ev_/ then @pokemon.ev_max?(change['field'].sub('ev_', '').to_sym)
        when 'status_condition' then !change['conditions']
          .include?(@pokemon.primary_status_condition)
        end
      end

      def independent_fainted?(change)
        %w[level max_pp].include?(change['field']) ||
          change['field'].start_with?('ev_')
      end

      def execute_effects
        @item.effects.each do |effect|
          execute_pokemon_changes(effect)
          execute_move_changes(effect)
        end
      end

      def execute_pokemon_changes(effect)
        (effect['pokemon_changes'] || []).each do |change|
          execute_pokemon_change(change) if pokemon_change_applies?(change)
        end
      end

      def execute_move_changes(effect)
        (effect['move_changes'] || []).each do |change|
          execute_move_change(change) if move_change_applies?(change)
        end
      end

      def execute_pokemon_change(change)
        case change['field']
        when 'current_hp' then execute_current_hp_change(change)
        when 'status_condition' then execute_remove_status_condition(change)
        when 'level' then execute_level_up(change)
        when /^ev_/ then execute_ev_change(change)
        end
      end

      def execute_move_change(change)
        case change['field']
        when 'max_pp' then execute_add_max_pp(change)
        end
      end

      def execute_level_up(_change)
        @pokemon.increment_level
      end

      def execute_ev_change(change)
        stat = change['field'].sub('ev_', '').to_sym
        @pokemon.add_ev(stat, change['change_by'])
      end

      def execute_remove_status_condition(_change)
        @pokemon.add_growth_event(GrowthEvents::RemoveStatusCondition)
      end

      def execute_add_max_pp(change)
        moves = @pokemon.moves.map do |move|
          next if move.max_pp_at_max?
          [move.name, change_for_move(move, change)]
        end.compact.to_h
        @pokemon.add_growth_event(GrowthEvents::IncreaseMaxPp, moves: moves)
      end

      def change_for_move(move, change)
        increase_by = if change['change_by_percent']
                        (move.move_type.pp.to_f *
                          (change['change_by_percent'].to_f / 100)).to_i
                      else
                        change['change_by']
                      end

        if change['change_by_max'] && increase_by > change['change_by_max']
          change['change_by_max']
        else
          increase_by
        end
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
