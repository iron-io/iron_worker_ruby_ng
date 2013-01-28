require 'iron_worker_ng/code/runtime/node'

module IronWorkerNG
  module Code
    class Node < IronWorkerNG::Code::Base
      def initialize(*args, &block)
        runtime(:node)

        super(*args, &block)
      end
    end
  end
end
