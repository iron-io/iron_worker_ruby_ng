
require_relative '../lib/iron_worker_ng'
require 'yaml'

cf = File.expand_path(File.join("~", "Dropbox", "configs", "iron_worker_ruby", "test", "config.yml"))
if File.exist?(cf)
  @config = YAML::load_file(cf)
else
  @config = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))
end

client = IronWorkerNG::Client.new(@config['iron_worker']['project_id'], @config['iron_worker']['token'])

client.upload do |code|
  code.merge_worker 'hello_worker.rb', 'HelloWorker'
end

client.queue('HelloWorker')

