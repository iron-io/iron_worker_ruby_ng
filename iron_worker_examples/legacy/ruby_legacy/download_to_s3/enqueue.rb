require 'iron_worker'
require 'time'
require_relative '../examples_helper'

require_relative 'download_into_s3_worker'

@config = ExamplesHelper.load_config

IronWorker.configure do |config|
  config.token = @config['iw']['token']
  config.project_id = @config['iw']['project_id']
end

worker = DownloadIntoS3Worker.new
worker.config = @config
worker.url = "http://2.bp.blogspot.com/-iSc4t8I0ejg/TyNOkvH1kQI/AAAAAAABAVk/MGdD2eXhFPA/s1600/testing-darth-vader-300x240.jpg"
worker.s3_key = "ironman.jpg"
worker.queue(:priority=>1)
worker.wait_until_complete
sleep 1
puts 'LOG:'
puts worker.get_log
