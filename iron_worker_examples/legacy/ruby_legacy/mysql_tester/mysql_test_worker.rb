require "iron_worker"
require "mysql2"

class MySQLTestWorker < IronWorker::Base

  merge_gem "sequel"

  attr_accessor :db_config

  def run
    log "\nRunning MySQLTestWorker..."

    log "\nConnecting to MySQL..."   
     
    #db = Sequel.connect(:adapter => 'mysql2', :host => '#{@db_config["host"]}:#{@db_config["port"]}', :database => @db_config.db_name, 
    #                   :user => @db_config.username, :password=>@db_config.password)

    db = Sequel.connect(:adapter => 'mysql2', :host => @db_config.host, :database => @db_config.db_name, 
                        :user => @db_config.username, :password=>@db_config.password)
 
    #db = Sequel.connect("mysql2://#{@db_config["username"]}:#{@db_config["password"]}@#{@db_config["host"]}:#{@db_config["port"]}/#{@db_config["db_name"]}")
    db = Sequel.connect(@db_config_uri)
    log "Connected.\n\n"   

    log "Printing database names......."
    db["SHOW DATABASES;"].each{|x| log x.inspect}
  end

end

