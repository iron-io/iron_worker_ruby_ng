#
# Sample worker that connects to MongoDB and iterates through a Mongo collection
# and puts all of the items into IndexTank for full text awesomeness searching.

require 'iron_worker'

class MongoToIndextankWorker < IronWorker::Base

  merge_gem 'faraday-stack', :require=>'faraday_stack'
  merge_gem 'indextank'
  merge_gem 'mongoid'
  
  merge 'person'

  # These values are passed in to make it easy to run the example. Some values (such
  # as index) could be placed in initialize() or directly inline to simplify things
  attr_accessor :mongo_host, :mongo_port, :mongo_username, :mongo_password,
                :mongo_db_name,
                :indextank_url, :indextank_index


  def run
    init_mongodb
    init_indextank

    log "saving person..."
    person = Person.new(:first_name => "Ludwig", :last_name => "Beethoven the #{rand(100)}")
    person.save!
    log person.inspect

    sleep 1

    @index = @indextank.indexes(indextank_index)

    log "querying persons..."
    persons = Person.find(:all, :conditions=>{:first_name=>"Ludwig"})
    persons.each do |p|
      log "indexing #{p.first_name} #{p.last_name} #{p.id}"
      log p.inspect
      doc_id = "person_#{p.id}"
      log doc_id
      @index.document(doc_id).add({:text=>"#{p.first_name} #{p.last_name}"})

    end


  end


  # Configures the MongoHQ settings using the Mongoid gem.
  def init_mongodb
    Mongoid.configure do |config|
      config.database = Mongo::Connection.new(mongo_host, mongo_port).db(mongo_db_name)
      config.database.authenticate(mongo_username, mongo_password)
      config.persist_in_safe_mode = false
    end
  end


  def init_indextank
    @indextank = IndexTank::Client.new(indextank_url)
  end

end
