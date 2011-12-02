# encoding: utf-8

require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'yard'
require 'rspec/core/rake_task'
require 'jeweler'


#
#  Jeweler Stuff
#
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "tom"
  gem.homepage = "http://github.com/moviepilot/tom"
  gem.license = "MIT"
  gem.summary = %Q{Parallel request dispatcher and merger for goliath.io}
  gem.description = %Q{ Tom uses Goliath to dispatch HTTP requests to multiple other APIs (via Adapters) in parallel. In a next step, a Merger merges the result and responds to the clients request.}
  gem.email = "jannis@gmail.com"
  gem.authors = ["Jannis Hermanns"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new


#
#  Rcov
#
require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end


#
#  RSpec
#
task :default => [:spec]
task :test => [:spec]
desc "run spec tests"
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = 'spec/**/*_spec.rb'
end


#
#  Yard
#
desc 'Generate documentation'
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', '-', 'LICENSE']
  t.options = ['--main', 'README.md', '--no-private']
end

