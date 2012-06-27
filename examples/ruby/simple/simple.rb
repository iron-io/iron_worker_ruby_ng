require 'iron_worker_ng'

IronCore::Logger.logger.level = ::Logger::DEBUG

# initializing client object
client = IronWorkerNG::Client.new(# optinal
                                  :scheme => 'https',
                                  :port => 443,
                                  :api_version => 2,
                                  :host => 'worker-aws-us-east-1.iron.io')

# creating code bundle

path = File.dirname(__FILE__) + '/sample_worker.rb'

# if not specified, name default to worker name converted from underscore to camel style
code = IronWorkerNG::Code.new do
  merge_exec path
end
#> code.name == 'SampleWorker'

# still can pass name in constructor and exec
code = IronWorkerNG::Code.new do
  name 'transmogrify'
  exec path
end
#> code.name == 'transmogrify'

# or in block (like other intance methods)
code = IronWorkerNG::Code.new do
  name 'transmogrify'
  merge_exec path
end

# once worker merged, following attempts will be ignored
code.merge_exec('anything')
#> code.features.find{|f| f.is_a? IronWorkerNG::Feature::Ruby::MergeExec::Feature }.path.end_with? '/worker.rb'

# if worker requires some gems,
# we can specify worker dependency on gem
code.merge_gem('jeweler2')
# or on Gemfile, which is recommended
code.merge_gemfile(File.dirname(__FILE__) + '/Gemfile',
                   :default, :extra)
# all those dependencies will be resolved using bundler gem

# upload code bundle to iron.io
client.codes_create(code)

# we can retrive code packages list
codes = client.codes_list
#> codes.map{|c| c.name}.include?('transmogrify')

code_info = codes.find{|c| c.name == 'transmogrify'}
# other way to get such info is codes.get:
same_code_info = client.codes_get(code_info.id)
#> same_code_info == code_info

# create task to run the bundle
task_id = client.tasks_create('transmogrify').id

# wait for the task to finish
client.tasks_wait_for(task_id)

# retriving task log
log = client.tasks_log(task_id) #> log == "hello\n" -- worker stdout is in log 

# cleanup
client.codes_delete(code_info.id)
