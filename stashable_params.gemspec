# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stashable_params/version'

Gem::Specification.new do |spec|
  spec.name          = "stashable_params"
  spec.version       = StashableParams::VERSION
  spec.authors       = ["Lin Reid"]
  spec.email         = ["linreid@gmail.com"]
  spec.description   = 'Easily stash your params for later use.'
  spec.summary       = 'stashable_params allows you temporarily stash params and unstash them when you need them.'
  spec.homepage      = 'https://github.com/linstula/stashable_params'
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
