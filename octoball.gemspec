# frozen_string_literal: true
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'octoball/version'

Gem::Specification.new do |s|
  s.name        = 'octoball'
  s.version     = Octoball::VERSION
  s.licenses    = ['MIT']
  s.summary     = "Octopus-like Database Sharding Helper for ActiveRecord 6.1+"
  s.description = "Octoball provides migration path to Rails 6.1+ for applications using Octopus gem and older Rails."
  s.authors     = ["Tomoki Sekiyama"]
  s.email       = 'tomoki.sekiyama@aktsk.jp'
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {spec}/*`.split("\n")
  s.homepage    = 'https://github.com/aktsk/octoball'
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.7.0'

  s.add_dependency 'activerecord', '>= 6' # need to be upadted to 6.1 after release
  s.add_dependency 'activesupport', '>= 6'

  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '>= 3'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'byebug'
end
