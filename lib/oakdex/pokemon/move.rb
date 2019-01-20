require 'forwardable'

module Oakdex
  class Pokemon
    # Represents Pokemon Move with PP
    class Move
      def self.create(move_id)
        move_type = Oakdex::Pokedex::Move.find!(move_id)
        new(move_type, move_type.pp, move_type.pp)
      end

      extend Forwardable

      attr_reader :max_pp
      attr_accessor :pp

      def_delegators :@move_type, :target, :priority, :accuracy,
                     :category, :power, :stat_modifiers,
                     :in_battle_properties

      def initialize(move_type, pp, max_pp)
        @move_type  = move_type
        @pp         = pp
        @max_pp     = max_pp
      end

      def name
        @move_type.names['en']
      end

      def type_id
        @move_type.type
      end

      def type
        Oakdex::Pokedex::Type.find!(type_id)
      end
    end
  end
end
