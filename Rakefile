require 'rubygems'
require 'rake'

require File.expand_path('../lib/iron_worker_ng/version', __FILE__)

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test
