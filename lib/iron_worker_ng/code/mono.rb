require 'iron_worker_ng/code/runtime/mono'

module IronWorkerNG
  module Code
    class Mono < IronWorkerNG::Code::Base
      def initialize(*args, &block)
        runtime(:mono)

        super(*args, &block)
      end
    end
  end
end
