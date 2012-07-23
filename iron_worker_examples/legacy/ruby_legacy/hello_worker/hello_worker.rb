#--
# Copyright (c) 2012 Chad Arimura
# Developed for www.iron.io
#
# HelloWorker is a very basic worker intended to show how easy it is to queue and run a worker.
# There are no dependencies aside from a www.iron.io account.
#
# 1. Enter your IronWorker credentials into hello_worker_runner.rb
# 2. Type 'ruby hello_worker_runner.rb'
#
#
# THESE EXAMPLES ARE INTENDED AS LEARNING AIDS FOR BUILDING WORKERS TO BE USED AT www.iron.io.
# THEY CAN BE USED IN YOUR OWN CODE AND MODIFIED AS YOU SEE FIT.
#
#++

require 'iron_worker'

class HelloWorker < IronWorker::Base

  attr_accessor :some_param

  def run
    log "Starting HelloWorker #{Time.now}\n"
    log "Hey. I'm a worker job, showing how this cloud-based worker thing works."
    log "I'll sleep for a little bit so you can see the workers running!"
    log "some_param --> #{some_param}\n"
    sleep 10
    log "Done running HelloWorker #{Time.now}"
  end


end