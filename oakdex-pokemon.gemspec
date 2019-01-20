$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'oakdex/pokemon/version'

Gem::Specification.new do |s|
  s.name        = 'oakdex-pokemon'
  s.version     = Oakdex::Pokemon::VERSION
  s.summary     = 'Pokémon Instance Representer'
  s.description = 'Pokémon Instance Representer, based on oakdex-pokedex'
  s.authors     = ['Jalyna Schroeder']
  s.email       = 'jalyna.schroeder@gmail.com'
  s.files       = Dir.glob('lib/**/**') + %w[README.md]
  s.homepage    = 'http://github.com/jalyna/oakdex-pokemon'
  s.license     = 'MIT'
  s.add_runtime_dependency 'oakdex-pokedex', '>= 0.4.0'
end
