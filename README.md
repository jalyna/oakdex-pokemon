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
  ability: 'Soundproof',
  nature: 'Bashful',
  item: 'Earth Plate',
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
```


### Exp Gain Calculation

```ruby
fainted = Oakdex::Pokemon.create('Pikachu', level: 10)
winner = Oakdex::Pokemon.create('Bulbasaur', level: 12)

Oakdex::Pokemon::ExperienceGainCalculator.calculate(fainted, winner) # => 269
Oakdex::Pokemon::ExperienceGainCalculator.calculate(fainted, winner, flat: true) # => 225
Oakdex::Pokemon::ExperienceGainCalculator.calculate(fainted, winner, winner_using_exp_share: true) # => 135
```



## Contributing

I would be happy if you want to add your contribution to the project. In order to contribute, you just have to fork this repository.

Please respect the [Code of Conduct](//github.com/jalyna/oakdex-pokemon/blob/master/CODE_OF_CONDUCT.md).

## License

MIT License. See the included MIT-LICENSE file.

## Credits

Logo Icon by [Roundicons Freebies](http://www.flaticon.com/authors/roundicons-freebies).
