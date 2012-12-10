out = `gem build iron_worker_ng.gemspec`
unless out =~ /File: (.*)$/
  puts "Failed to build gem: #{out}"
  exit(1)
end
puts `gem install #{$1}`

require_relative '../lib/iron_worker_ng.rb'
require_relative 'iron_io_config.rb'

client = IronWorkerNG::Client.new

code = IronWorkerNG::Code::Base.new do
  name 'NgTestsWorker'
  runtime 'ruby'

  exec 'test/ng_tests_worker.rb'
  gemfile 'Gemfile', :default, :development, :test

  Dir.glob('*').each do |p|
    dir  p, 'iwng' if File.directory?  p
    file p, 'iwng' if File.file? p
  end

  iron_io_config 'iwng'
end

puts client.codes.create(code)

task = client.tasks.create 'NgTestsWorker', args: $*.join(' ')

client.tasks.wait_for task.id

puts '-' * 80

puts client.tasks.log(task.id)
