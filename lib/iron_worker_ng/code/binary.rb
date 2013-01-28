require 'iron_worker_ng/code/runtime/binary'

module IronWorkerNG
  module Code
    class Binary < IronWorkerNG::Code::Base
      def initialize(*args, &block)
        runtime(:binary)

        super(*args, &block)
      end
    end
  end
end
