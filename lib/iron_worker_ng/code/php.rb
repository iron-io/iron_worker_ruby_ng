require 'iron_worker_ng/code/runtime/php'

module IronWorkerNG
  module Code
    class PHP < IronWorkerNG::Code::Base
      def initialize(*args, &block)
        runtime(:python)

        super(*args, &block)
      end
    end
  end
end
