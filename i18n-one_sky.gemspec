# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "i18n-one_sky/version"

Gem::Specification.new do |s|
  s.name        = "i18n-one_sky"
  s.version     = I18n::Onesky::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Junjun Olympia"]
  s.email       = ["romeo.olympia@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/i18n-one_sky"
  s.summary     = %q{I18n extensions using OneSky -- the community-powered translation service.}
  s.description = %q{A set of I18n extensions that use OneSky. At its most basic, this allows you to easily submit translation requests to the OneSky service and download available translations as Simple backend YAML files.}

  s.rubyforge_project = "i18n-one_sky"

  s.add_dependency "i18n", "~> 0.5.0"
  s.add_dependency "one_sky", "~> 0.0.2"
  s.add_dependency "thor", "~> 0.14.4"

  s.add_development_dependency "rspec", "~> 2.2.0"
  s.add_development_dependency "bundler", "~> 1.0.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
