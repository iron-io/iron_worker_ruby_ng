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
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name = "iron_worker_ng"
  gem.homepage = "http://github.com/iced/iron_worker_ruby_ng"
  gem.license = "MIT"
  gem.summary = %Q{IronWorkerNG}
  gem.description = %Q{New generation ruby client for IronWorke}
  gem.email = "andrew.kirilenko@gmail.com"
  gem.authors = ["Andrew Kirilenko"]
  gem.files.exclude('.document', 'Gemfile', 'Gemfile.lock', 'Rakefile', 'iron_worker_ng.gemspec', 'sample/**')
end

Jeweler::RubygemsDotOrgTasks.new
