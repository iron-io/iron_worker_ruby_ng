require 'iron_worker'
require 'yaml'

require_relative 's3_worker'

config_data = YAML.load_file '../_config.yml'

IronWorker.configure do |config|
  config.token = config_data['iw']['token']
  config.project_id = config_data['iw']['project_id']
end

worker = S3Worker.new
worker.aws_access = config_data['aws']['access_key']
worker.aws_secret = config_data['aws']['secret_key']
worker.aws_s3_bucket_name = config_data['aws']['s3_bucket_name']
worker.image_url = config_data['image_url']

#worker.run_local
worker.queue(:priority => 1)

status = worker.wait_until_complete
p status
puts worker.get_log
