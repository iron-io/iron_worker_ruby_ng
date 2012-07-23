#
# This worker is a scheduled job. When it gets enqueued, it cycles
# through the array of twitter_names and creates a worker for each
# success set of three names.
#
# You will want to check two logs - 1 for this worker, the other
# for KloutHelloWorker.
#

require 'iron_worker'

class MasterWorker < IronWorker::Base

  merge_worker "../klout.com/klout_hello_worker.rb", "KloutHelloWorker"

  attr_accessor :klout_api_key, :klout_twitter_names
  attr_accessor :slice_num

  def run
    1.step(@klout_twitter_names.length, @slice_num) { |i|      
      slave_worker = KloutHelloWorker.new
      slave_worker.klout_api_key = @klout_api_key
      slave_worker.klout_twitter_names = @klout_twitter_names.slice(i, @slice_num)

      log "Queuing up worker with names:"
      log "  #{slave_worker.klout_twitter_names}"
      
      slave_worker.queue
    }

  end

end