require 'bundler'
require 'tmpdir'

tmpdir = Dir.mktmpdir
File.open(tmpdir + '/Gemfile', 'w') do |f|
  f << File.read('Gemfile')
  f << File.read('test/Gemfile')
end
Dir.chdir tmpdir do
  Bundler.setup
end

$LOAD_PATH.unshift 'lib'

require 'iron_worker_ng'
require_relative 'test/iron_io_config.rb'

client = IronWorkerNG::Client.new

code = IronWorkerNG::Code::Ruby.new do
  exec 'ng_tests_worker.rb'
  gemfile 'Gemfile'
  gemfile 'test/Gemfile'

  Dir.glob('*').each do |p|
    dir  p, 'iwng' if File.directory?  p
    file p, 'iwng' if File.file? p
  end

  iron_io_config 'iwng'
end

puts client.codes.create(code)

puts code.create_zip

task = client.tasks.create 'NgTestsWorker', args: $*.join(' ')

client.tasks.wait_for task.id

puts '-' * 80

puts client.tasks.log(task.id)
