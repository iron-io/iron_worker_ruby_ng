require "iron_worker"

class SimpleDBTestWorker < IronWorker::Base

  attr_accessor :aws_access, :aws_secret

  merge_gem "aws"

  def run
    log "\nRunning SimpleDBTestWorker...\n"

    log "\nConnecting to AWS SimpleDB..."
    sdb = Aws::SdbInterface.new(@aws_access, @aws_secret)
    log "Connected."

    log "\nGetting domains..."
    domains = sdb.list_domains[:domains]
    log "Gotten."
    
    log "\nListing domains..."
    domains.each{|x| log x.inspect }
 
    log "\nFinished processing SimpleDBTestWorker.\n\n"
    end
end
