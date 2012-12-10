require 'iron_worker_ng'

client = IronWorkerNG::Client.new

# master code package
master_code = IronWorkerNG::Code::Ruby.new
master_code.exec 'master_worker.rb'
master_code.gem 'iron_worker_ng' # we need it to queue slave workers

# slave code package
slave_code = IronWorkerNG::Code::Ruby.new
slave_code.exec 'slave_worker.rb'

# upload both code packages
client.codes.create(master_code)
client.codes.create(slave_code)
