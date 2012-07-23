
require 'iron_worker'
require 'json'

class DeserializeWorker < IronWorker::Base

  merge './model_good'
  merge './model_good2'
  merge './model_no_good'

  attr_accessor :model_good, :model_good2, :model_no_good

  def run
    log "\n"
    log "model_good.class: [#{model_good.class}]"
    p model_good
    
    log "\n"
    log "model_good2.class: [#{model_good2.class}]"
    p model_good2
   
    log "\n"
    log "model_no_good.class: [#{model_no_good.class}]"
    p model_no_good
    log "\n"
  end

end