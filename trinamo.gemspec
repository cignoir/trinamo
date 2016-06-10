# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trinamo/version'

Gem::Specification.new do |spec|
  spec.name          = "trinamo"
  spec.version       = Trinamo::VERSION
  spec.authors       = ["cignoir"]
  spec.email         = ["cignoir@gmail.com"]

  spec.summary       = %q{DDL Generator for Hive from YAML}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/cignoir/trinamo"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "unindent"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency(%q<coveralls>, [">= 0"])
end
