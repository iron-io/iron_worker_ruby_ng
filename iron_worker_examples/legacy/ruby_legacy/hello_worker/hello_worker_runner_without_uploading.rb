require 'iron_worker'
require 'yaml'
def wait_for_task(params={})
  tries  = 0
  status = nil
  sleep 1
  while tries < 60
    status = status_for(params)
    puts 'status = ' + status.inspect
    if status["status"] == "complete" || status["status"] == "error"
      break
    end
    sleep 2
  end
  status
end

def status_for(ob)
  if ob.is_a?(Hash)
    IronWorker.service.status(ob["id"])
  else
    ob.status
  end
end

# Create a project at www.iron.io and enter your credentials below
# Configuration method of v2 of IronWorker gem
# See the Projects tab for PROJECT_ID and Accounts/API Tokens tab for TOKEN
#-------------------------------------------------------------------------
config_data = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = config_data["iw"]["token"]
  config.project_id = config_data["iw"]["project_id"]
end

# Configuration for v1 of IronWorker gem
#-------------------------------------------------------------------------
#IronWorker.configure do |config|
#  config.access_key = 'IRONWORKER_ACCESS_KEY'
#  config.secret_key = 'IRONWORKER_SECRET_KEY'
#end
#-------------------------------------------------------------------------

# queue already uploaded worker with an arbitrary parameter
data={}
#set params without class instance
data[:attr_encoded] = Base64.encode64({'@some_param'=>'Im running without uploading'}.to_json)
#set ironworker params
data[:sw_config] = IronWorker.config.get_atts_to_send
#queue worker
worker_info = IronWorker.service.queue('HelloWorker', data,:priority=>2)
#waiting until comlete
puts worker_info.inspect
wait_for_task(worker_info["tasks"][0])