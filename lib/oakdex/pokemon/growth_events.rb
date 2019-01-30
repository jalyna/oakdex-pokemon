module Oakdex
  class Pokemon
    # Represents Growth events namespace (Moves, Evolution etc.)
    module GrowthEvents
    end
  end
end

require 'oakdex/pokemon/growth_events/base'
require 'oakdex/pokemon/growth_events/gained_exp'
require 'oakdex/pokemon/growth_events/gained_ev'
require 'oakdex/pokemon/growth_events/learn_move'
require 'oakdex/pokemon/growth_events/level_up'
require 'oakdex/pokemon/growth_events/forgot_and_learned_move'
require 'oakdex/pokemon/growth_events/did_not_learn_move'
require 'oakdex/pokemon/growth_events/did_evolution'
require 'oakdex/pokemon/growth_events/skipped_evolution'
require 'oakdex/pokemon/growth_events/evolution'
require 'oakdex/pokemon/growth_events/add_hp'
require 'oakdex/pokemon/growth_events/revive'
require 'oakdex/pokemon/growth_events/remove_status_condition'
