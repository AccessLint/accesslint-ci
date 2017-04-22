# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'accesslint/ci/version'

Gem::Specification.new do |spec|
  spec.name          = "accesslint-ci"
  spec.version       = Accesslint::Ci::VERSION
  spec.authors       = ["Cameron Cundiff"]
  spec.email         = ["hello@thoughtbot.com"]

  spec.summary       = %q{Run accessibility tests in CI builds}
  spec.description   = %q{accesslint-ci runs accessibility tests in CI and comments on corresponding GitHub pull requests}
  spec.homepage      = "https://www.github.com/accesslint/accesslint-ci"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = %w[accesslint-ci]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "climate_control", "~> 0.1.0"
  spec.add_development_dependency "dotenv", "~> 2.2.0"
  spec.add_development_dependency "pry-byebug", "~> 3.4.2"
  spec.add_development_dependency "rake", "~> 12.0.0"
  spec.add_development_dependency "rspec", "~> 3.5.0"

  spec.add_dependency "rest-client", "~> 2.0.1"
  spec.add_dependency "thor", "~> 0.19.4"
end
