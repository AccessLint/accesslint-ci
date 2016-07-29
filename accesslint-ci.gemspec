# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'accesslint/ci/version'

Gem::Specification.new do |spec|
  spec.name          = "accesslint-ci"
  spec.version       = Accesslint::Ci::VERSION
  spec.authors       = ["Cameron Cundiff"]
  spec.email         = ["cameron@thoughtbot.com"]

  spec.summary       = %q{Run accesslint accessibility scanner in CI}
  spec.description   = %q{Run accesslint-cli accessibility assertions against a host url}
  spec.homepage      = "https://www.github.com/accesslint/accesslint-ci.rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "dotenv"
  spec.add_dependency "thor"
end
