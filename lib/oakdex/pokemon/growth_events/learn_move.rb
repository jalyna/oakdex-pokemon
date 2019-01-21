require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When pokemon could learn move
    class LearnMove < Base
      def message
        if move_slot_left?
          "#{@pokemon.name} learned #{@options[:move_id]}."
        else
          "#{@pokemon.name} wants to learn #{@options[:move_id]} but has already 4 moves."
        end
      end

      def possible_actions
        return [] if move_slot_left?
        [not_learn_action] + unlearn_moves.keys
      end

      def execute(action = nil)
        if move_slot_left?
          @pokemon.learn_new_move(@options[:move_id])
          if available_evolution
            @pokemon.add_growth_event(GrowthEvents::Evolution,
                                      evolution: available_evolution,
                                      after: self)
          end
        else
          if action == not_learn_action
            @pokemon.add_growth_event(GrowthEvents::DidNotLearnMove,
                                      move_id: @options[:move_id], after: self)
          else
            move_id = unlearn_moves[action]
            @pokemon.learn_new_move(@options[:move_id], move_id)
            @pokemon.add_growth_event(GrowthEvents::ForgotAndLearnedMove,
                                      move_id: @options[:move_id],
                                      forgot_move_id: move_id,
                                      after: self)
          end
        end
        remove_event
      end

      private

      def available_evolution
        @available_evolution ||= Oakdex::Pokemon::EvolutionMatcher
          .new(@pokemon, 'move_learned', move_id: @options[:move_id]).evolution
      end

      def not_learn_action
        "Do not learn #{@options[:move_id]}"
      end

      def unlearn_moves
        @pokemon.moves.map do |move|
          ["Forget #{move.name}", move.name]
        end.to_h
      end

      def move_slot_left?
        @pokemon.moves.size < 4
      end
    end
  end
end
