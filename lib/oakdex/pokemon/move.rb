require 'forwardable'

module Oakdex
  class Pokemon
    # Represents Pokemon Move with PP
    class Move
      extend Forwardable

      attr_reader :max_pp
      attr_accessor :pp

      def_delegators :@move_type, :target, :priority, :accuracy,
                     :category, :power, :type, :stat_modifiers,
                     :in_battle_properties

      def initialize(move_type, pp, max_pp)
        @move_type  = move_type
        @pp         = pp
        @max_pp     = max_pp
      end

      def name
        @move_type.names['en']
      end
    end
  end
end
