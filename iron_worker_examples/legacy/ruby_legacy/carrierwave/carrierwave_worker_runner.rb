require 'yaml'
require 'carrierwave' # must be available at queue time

require_relative 'carrierwave_worker'

conf = YAML.load_file 'carrierwave.yml'

IronWorker.configure do |config|
  config.token = conf['iw']['token']
  config.project_id = conf['iw']['project_id']
end

worker = CarrierWaveWorker.new
worker.aws_access_key = conf['aws']['access_key']
worker.aws_secret_key = conf['aws']['secret_key']
worker.aws_bucket = conf['aws']['bucket']
worker.image_file = conf['image_file']

worker.queue
