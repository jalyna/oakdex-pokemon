# <img src="https://v20.imgup.net/oakdex_logfbad.png" alt="fixer" width=282>

[![Gem Version](https://badge.fury.io/rb/oakdex-pokemon.svg)](https://badge.fury.io/rb/oakdex-pokemon) [![Build Status](https://travis-ci.org/jalyna/oakdex-pokemon.svg?branch=master)](https://travis-ci.org/jalyna/oakdex-pokemon) [![Maintainability](https://api.codeclimate.com/v1/badges/9917f32f23833238aef9/maintainability)](https://codeclimate.com/github/jalyna/oakdex-pokemon/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/9917f32f23833238aef9/test_coverage)](https://codeclimate.com/github/jalyna/oakdex-pokemon/test_coverage)

Based on [oakdex-pokedex](https://github.com/jalyna/oakdex-pokedex).

Used as a representation for Pokémon across other Projects like [oakdex-battle](https://github.com/jalyna/oakdex-battle) and [oakdex-breeding](https://github.com/jalyna/oakdex-breeding).

## Getting Started

```ruby
require 'oakdex/pokemon'

pikachu = Oakdex::Pokemon.create('Pikachu', level: 12)
bulbasaur = Oakdex::Pokemon.create('Bulbasaur', { # many options available
  exp: 120,
  gender: 'female',
  ability_id: 'Soundproof',
  nature_id: 'Bashful',
  hp: 2,
  iv: {
    hp: 8,
    atk: 12,
    def: 31,
    sp_atk: 12,
    sp_def: 5,
    speed: 14
  },
  ev: {
    hp: 8,
    atk: 12,
    def: 99,
    sp_atk: 4,
    sp_def: 12,
    speed: 14
  },
  moves: [
    ['Swords Dance', 12, 30],
    ['Cut', 40, 44]
  ],
  original_trainer: 'Cool trainer name',
  item_id: 'Lucky Egg',
  wild: true,
  primary_status_condition: 'sleep'
})

pikachu.gender # => female
pikachu.name # => Pikachu
pikachu.level # => 12
pikachu.moves.map { |p| "#{p.name} #{p.pp}" } # => ["Quick Attack 30", "Tail Whip 30", "Growl 40", "Thunder Shock 30"]
pikachu.hp # => 34
pikachu.atk # => 18
pikachu.current_hp # => 34
pikachu.traded? # => false
pikachu.change_hp_by(38)
pikachu.current_hp # => 0
pikachu.change_pp_by('Thunder Shock', -1)
pikachu.moves.map { |p| "#{p.name} #{p.pp}" } # => ["Quick Attack 30", "Tail Whip 30", "Growl 40", "Thunder Shock 29"]

pikachu.exp # => 1728
pikachu.increment_level
pikachu.level # => 12
pikachu.exp # => 1728

# Pikachu learns Electro Ball in Level 13
while pikachu.growth_event? do
  e = pikachu.growth_event
  if e.read_only?
    puts e.message
    e.execute
  else
    puts e.message
    puts e.possible_actions # => ['Forget Quick Attack', ..., 'Do not learn Electro Ball']
    e.execute(e.possible_actions.sample)
  end
end
pikachu.level # => 13
pikachu.exp # => 2197

# Calculate exp from won battles
fainted_opponent = bulbasaur
pikachu.gain_exp_from_battle(fainted_opponent, using_exp_share: false, flat: false)

# Evolution by level
charmander = Oakdex::Pokemon.create('Charmander', level: 15)
charmander.increment_level
# Charmander envolves to Charmeleon
while charmander.growth_event? do
  e = charmander.growth_event
  if e.read_only?
    puts e.message
    e.execute
  else
    puts e.message
    puts e.possible_actions # => ['Continue', 'Skip']
    e.execute(e.possible_actions.first)
  end
end
charmander.level # => 16
charmander.name # => Charmeleon

# Evolution by trade
feebas = Oakdex::Pokemon.create('Feebas', level: 12, item_id: 'Prism Scale')
trainer = OpenStruct.new(name: 'My Awesome Trainer')
feebas.trade_to(trainer)
# Feebas envolves to Milotic
while feebas.growth_event? do
  e = feebas.growth_event
  if e.read_only?
    puts e.message
    e.execute
  else
    puts e.message
    puts e.possible_actions # => ['Continue', 'Skip']
    e.execute(e.possible_actions.first)
  end
end
feebas.name # => Milotic
feebas.trainer # => trainer

# Evolution by item
exeggcute = Oakdex::Pokemon.create('Exeggcute', level: 12)
exeggcute.usable_item?('Leaf Stone') # => true
exeggcute.use_item('Leaf Stone')
# Exeggcute envolves to Exeggutor
while exeggcute.growth_event? do
  e = exeggcute.growth_event
  if e.read_only?
    puts e.message
    e.execute
  else
    puts e.message
    puts e.possible_actions # => ['Continue', 'Skip']
    e.execute(e.possible_actions.first)
  end
end
exeggcute.name # => Exeggutor


# Item Usage
charmander = Oakdex::Pokemon.create('Charmander', level: 15, hp: 32)
charmander.usable_item?('Potion') # => true
charmander.use_item('Potion')
# Charmander gets HP
while charmander.growth_event? do
  e = charmander.growth_event
  if e.read_only?
    puts e.message
    e.execute # => gains ~8HP
  end
end
charmander.hp # => 40
charmander.usable_item?('Potion') # => false


charmander = Oakdex::Pokemon.create('Charmander', level: 15, primary_status_condition: 'poison')
charmander.usable_item?('Antidote') # => true
charmander.use_item('Antidote')
# Charmander heals status condition
while charmander.growth_event? do
  e = charmander.growth_event
  if e.read_only?
    puts e.message
    e.execute # => heals poison
  end
end
charmander.primary_status_condition # => nil
charmander.usable_item?('Antidote') # => false
```


## Contributing

I would be happy if you want to add your contribution to the project. In order to contribute, you just have to fork this repository.

Please respect the [Code of Conduct](//github.com/jalyna/oakdex-pokemon/blob/master/CODE_OF_CONDUCT.md).

## License

MIT License. See the included MIT-LICENSE file.

## Credits

Logo Icon by [Roundicons Freebies](http://www.flaticon.com/authors/roundicons-freebies).
