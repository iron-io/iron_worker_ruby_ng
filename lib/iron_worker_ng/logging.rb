require 'logger'

class StandardError
  def report
    %{#{self.class}: #{message}\n#{backtrace.join("\n")}}
  end
end

module IronWorkerNG
  @@logger = Logger.new(STDERR)

  def self.logger
    @@logger
  end
  def self.logger=(other)
    @@logger = other
  end
end
