require 'logger'

module IronWorkerNG
  module Logger
    def self.logger
      @logger ||= ::Logger.new(STDOUT)
    end

    def self.logger=(logger)
      @logger = logger
    end

    def self.fatal(msg)
      self.logger.fatal("IronWorkerNG") { msg }
    end

    def self.error(msg)
      self.logger.error("IronWorkerNG") { msg }
    end

    def self.warn(msg)
      self.logger.warn("IronWorkerNG") { msg }
    end

    def self.info(msg)
      self.logger.info("IronWorkerNG") { msg }
    end

    def self.debug(msg)
      self.logger.debug("IronWorkerNG") { msg }
    end
  end
end
