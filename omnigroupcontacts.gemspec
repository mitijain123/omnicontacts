# encoding: utf-8
require File.expand_path('../lib/omnigroupcontacts', __FILE__)

Gem::Specification.new do |gem|
  gem.name = 'omnigroupcontacts'
  gem.description = %q{A generalized Rack middleware for importing group contacts from gmail.}
  gem.authors = ['Mitesh Jain']
  gem.email = ['mitijain123@gmail.com']

  gem.add_runtime_dependency 'rack'
  gem.add_runtime_dependency 'json'

  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'rspec'

  gem.version = OmniGroupContacts::VERSION  
  gem.homepage = 'http://github.com/mitijain123/omnigroupcontacts'
  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new('>= 1.3.6') if gem.respond_to? :required_rubygems_version=
  gem.summary = gem.description
  gem.test_files = `git ls-files -- {spec}/*`.split("\n")
end
