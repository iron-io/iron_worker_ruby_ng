require 'logger'

module IronWorkerNG
  @logger = Logger.new($stdout)

  def self.logger
    @logger
  end

  def self.logger=(logger)
    @logger = logger
  end
end
