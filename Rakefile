# encoding: utf-8

require 'rubygems'
require 'bundler'
require 'rspec'
require 'rspec/core/rake_task'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "po"
  gem.homepage = "http://github.com/relaxdiego/po"
  gem.license = "MIT"
  gem.summary = "Ruby implementation of the Page Object pattern"
  gem.description = "Ruby implementation of the Page Object pattern"
  gem.email = "mmaglana@gmail.com"
  gem.authors = ["Mark Maglana"]
end
Jeweler::RubygemsDotOrgTasks.new