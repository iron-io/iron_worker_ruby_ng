require 'iron_worker_ng'

# setting log level to DEBUG
IronCore::Logger.logger.level = ::Logger::DEBUG

# initializing client object
client = IronWorkerNG::Client.new(# optinal
                                  :scheme => 'https',
                                  :port => 443,
                                  :api_version => 2,
                                  :host => 'worker-aws-us-east-1.iron.io')

# creating code bundle

# preferred way is using name.worker file
code = IronWorkerNG::Code::Base.new 'sample' # sample.worker is used

# variations:
code = IronWorkerNG::Code::Base.new 'sample.worker'
code = IronWorkerNG::Code::Base.new :workerfile => 'sample.worker'

# also we can pass block with same content as workerfile:
code = IronWorkerNG::Code::Base.new do
  runtime 'ruby' # not necessary here, since 'ruby' is default runtime
  exec 'sample_worker.rb'
end
# if not specified, name defaults to executable without extension
puts "default name is #{code.name}" # 'sample_worker'

# still can pass name in constructor and executable
code = IronWorkerNG::Code::Base.new(:name => 'transmogrify',
                                    :exec => 'sample_worker.rb')
puts "from hash: name is #{code.name}, exec is #{code.exec.path}"
# name is transmogrify, exec is sample_worker.rb

# or in block (like other intance methods)
code = IronWorkerNG::Code::Base.new do
  name 'transmogrify'
  exec 'sample_worker.rb'
end
puts "from block: name is #{code.name}, exec is #{code.exec.path}"
# name is transmogrify, exec is sample_worker.rb

# once worker merged, following attempts will be ignored
code.merge_exec('anything')
puts "exec is #{code.exec.path}" # exec is sample_worker.rb

# if worker requires some gems,
# we can specify worker dependency on gem
code.merge_gem('bundler')
# or on Gemfile, which is recommended
code.merge_gemfile('Gemfile',
                   :default, :extra) # remaining arguments are groups to be used
# all those dependencies will be resolved using bundler gem

# upload code bundle to iron.io
code_info = client.codes_create(code)
# OpenStruct with result message is returned, with 'id' field if succeed
puts "code id is #{code_info.id}, message is #{code_info.msg}"

# we can retrive code infos list (pagination is enforced),
# with optional filter by creation time
code_infos = client.codes.list(:per_page => 100, # 30 by default, 100 at max
                               :page => 0,
                               :from_time => (Time.now - 60 * 60).to_i)
# which is array of OpenStructs with several useful fields
puts "#{code_infos.size} codes created last hour"

# with some info about code package
code_info = code_infos.find{|c| c.name == 'transmogrify'}
puts "transmogrify code info #{code_info.marshal_dump}"

# other way to get such info is codes.get:
code_info = client.codes_get(code_info.id)
puts "another transmogrify code info #{code_info.marshal_dump}"

# create task to run the bundle
task = client.tasks_create('transmogrify')
puts "task created: #{task.marshal_dump}"

# wait for the task to finish
task = client.tasks_wait_for(task.id, :sleep => 2) do
  # every 2 seconds will get task info and yield it if block is given
  |task|
  puts "waiting, status is #{task.status}"
end
puts "task finished with status #{task.status}"

# retriving task log
log = client.tasks_log(task.id)
puts log
