require File.expand_path('runtime/go', File.dirname(__FILE__))

module IronWorkerNG
  module Code
    class Go < IronWorkerNG::Code::Base
      def initialize(*args, &block)
        runtime(:go)

        super(*args, &block)
      end
    end
  end
end
