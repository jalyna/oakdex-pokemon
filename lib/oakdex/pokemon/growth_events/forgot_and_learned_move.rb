require 'forwardable'

class Oakdex::Pokemon
  module GrowthEvents
    # When move was learnt and other move was forgotten
    class ForgotAndLearnedMove < Base
      def message
        "#{@pokemon.name} learned #{@options[:move_id]} and forgot #{@options[:forgot_move_id]}."
      end
    end
  end
end
