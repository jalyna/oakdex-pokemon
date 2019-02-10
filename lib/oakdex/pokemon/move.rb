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

      def inspect
        fields = instance_variables.map do |name|
          if name == :@move_type
            "#{name}=#<Oakdex::Pokedex::Move #{@move_type.name}>"
          else
            "#{name}=#{instance_variable_get(name)}"
          end
        end
        "#<#{self.class.name}:#{object_id} #{fields.join(', ')}>"
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

      def to_h
        {
          move_id: @move_type.name,
          pp: @pp,
          max_pp: @max_pp
        }
      end
    end
  end
end
