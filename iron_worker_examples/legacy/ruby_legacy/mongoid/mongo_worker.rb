# Sample worker that connects to MongoDB and performs some operations.

require 'iron_worker'

class MongoWorker < IronWorker::Base

  merge_gem 'mongoid'
  merge 'person'

  def run
    # Load appropriate settings from the YAML file, based on the value of Rails.env or ENV['RACK_ENV']
    Mongoid.load!("mongoid.yml")

    log "saving person..."
    person = Person.new(:first_name => "Ludwig", :last_name => "Beethoven the #{rand(100)}")
    person.save!
    log person.inspect

    sleep 2

    log "querying persons..."

    persons = Person.find(:all, :conditions=>{:first_name=>"Ludwig"})
    persons.each do |p|
      log "found #{p.first_name} #{p.last_name}"
    end
  end
end
