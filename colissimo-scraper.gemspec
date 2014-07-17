# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'colissimo_scraper/version'

Gem::Specification.new do |spec|
  spec.name          = "colissimo-scraper"
  spec.version       = ColissimoScraper::VERSION
  spec.authors       = ["Raimondas Valickas"]
  spec.email         = ["raimondas@vinted.com"]
  spec.summary       = %q{Scraps Colisimo delivery page for tracking information}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
