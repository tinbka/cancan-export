# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cancan/export/version'

Gem::Specification.new do |spec|
  spec.name          = "cancan-export"
  spec.version       = CanCan::Export::VERSION
  spec.authors       = ["Sergey Baev"]

  spec.summary       = "Exports CanCan rules to the client-side."
  spec.homepage      = "https://github.com/tinbka/cancan-export"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  
  spec.add_dependency "gon"
  spec.add_dependency "coffee-rails"
end
