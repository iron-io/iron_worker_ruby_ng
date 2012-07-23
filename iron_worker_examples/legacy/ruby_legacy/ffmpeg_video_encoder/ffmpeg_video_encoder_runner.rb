require 'yaml'
require 'iron_worker'
require 'active_support/core_ext'

require_relative "ffmpeg_video_encoder_worker.rb"

#-------------------------------------------------------------------------
def self.wait_for_task(params={})
  tries  = 0
  status = nil
  sleep 1
  while tries < 60
    status = status_for(params)
    #puts 'status = ' + status.inspect
    if status["status"] == "complete" || status["status"] == "error"
      break
    end
    sleep 2
  end
  status
end

def self.status_for(ob)
  if ob.is_a?(Hash)
    ob[:schedule_id] ? WORKER.schedule_status(ob[:schedule_id]) : WORKER.status(ob[:task_id])
  else
    ob.status
  end
end
#-------------------------------------------------------------------------
config_data = YAML.load_file('../_config.yml')

IronWorker.configure do |config|
  config.token = config_data["iw"]["token"]
  config.project_id = config_data["iw"]["project_id"]
end

#-------------------------------------------------------------------------

worker = FFmpegVideoEncoderWorker.new
worker.output_file_name = 'output.mp4'

worker.queue

wait_for_task(worker)

puts "\nTask ended. Operation log:\n\n"

puts worker.get_log