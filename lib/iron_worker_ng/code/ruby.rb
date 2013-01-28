require 'iron_worker_ng/code/runtime/ruby'

module IronWorkerNG
  module Code
    class Ruby < IronWorkerNG::Code::Base
      def initialize(*args, &block)
        runtime(:ruby)

        super(*args, &block)
      end
    end
  end
end
