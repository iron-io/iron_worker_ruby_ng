puts `rake install`

require 'iron_worker_ng'
require_relative 'iron_io_config.rb'

client = IronWorkerNG::Client.new

code = IronWorkerNG::Code::Base.new do
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
