module Oakdex
  class Pokemon
    # Creates Pokemon instance and prefills attributes
    class Factory
      REQUIRED_ATTRIBUTES = %i[exp gender ability_id nature_id hp iv ev moves]
      OPTIONAL_ATTRIBUTES = %i[
        original_trainer
        primary_status_condition
        wild
        item_id
        amie
        friendship
      ]

      class << self
        def create(species, options = {})
          factory = new(species, options)
          attributes = Hash[(REQUIRED_ATTRIBUTES +
            OPTIONAL_ATTRIBUTES).map do |attr|
                              [attr, factory.send(attr)]
                            end]
          Pokemon.new(species.names['en'], attributes)
        end
      end

      def initialize(species, options = {})
        @species = species
        @options = options
      end

      private

      def primary_status_condition
        @options[:primary_status_condition]
      end

      def original_trainer
        @options[:original_trainer]
      end

      def wild
        @options[:wild]
      end

      def friendship
        @options[:friendship] || @species.base_friendship
      end

      def item_id
        @options[:item_id]
      end

      def amie
        @options[:amie]
      end

      def moves
        if @options[:moves]
          @options[:moves].map do |move_data|
            Move.new(
              Oakdex::Pokedex::Move.find!(move_data[0]),
              move_data[1],
              move_data[2]
            )
          end
        else
          (generate_available_moves + additional_moves).take(4)
        end
      end

      def generate_available_moves
        available_moves.sample(4).map do |move_name|
          move_type = Oakdex::Pokedex::Move.find!(move_name)
          Move.new(move_type, move_type.pp, move_type.pp)
        end
      end

      def additional_moves
        return [] unless @options[:additional_moves]
        @options[:additional_moves].map do |move_name|
          move_type = Oakdex::Pokedex::Move.find!(move_name)
          Move.new(move_type, move_type.pp, move_type.pp)
        end
      end

      def available_moves
        @species.learnset.map do |m|
          m['move'] if m['level'] && m['level'] <= level
        end.compact
      end

      def ability_id
        if @options[:ability_id]
          @options[:ability_id]
        else
          abilities.sample['name']
        end
      end

      def abilities
        @species.abilities.select { |a| !a['hidden'] && !a['mega'] }
      end

      def exp
        @options[:exp] || Stat.exp_by_level(
          @species.leveling_rate,
          @options[:level]
        )
      end

      def level
        Stat.level_by_exp(@species.leveling_rate, exp)
      end

      def hp
        return @options[:hp] if @options[:hp]
        Stat.initial_stat(:hp,
                          level: level,
                          iv: iv,
                          ev: ev,
                          base_stats: @species.base_stats,
                          nature: nature
                         )
      end

      def iv
        return @options[:iv] if @options[:iv]
        @iv ||= Hash[Pokemon::BATTLE_STATS.map do |stat|
          [stat, rand(0..31)]
        end]
      end

      def ev
        return @options[:ev] if @options[:ev]
        @ev ||= Hash[Pokemon::BATTLE_STATS.map do |stat|
          [stat, 0]
        end]
      end

      def gender
        return @options[:gender] if @options[:gender]
        return 'neuter' unless @species.gender_ratios
        calculate_gender
      end

      def calculate_gender
        if rand(1..1000) <= @species.gender_ratios['male'] * 10
          'male'
        else
          'female'
        end
      end

      def nature_id
        @nature_id ||= if @options[:nature_id]
                         @options[:nature_id]
                       else
                         Oakdex::Pokedex::Nature.all.values.sample.names['en']
                       end
      end

      def nature
        @nature ||= Oakdex::Pokedex::Nature.find!(nature_id)
      end
    end
  end
end
