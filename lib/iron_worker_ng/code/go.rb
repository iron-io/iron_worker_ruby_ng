require 'iron_worker_ng/code/runtime/go'

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
