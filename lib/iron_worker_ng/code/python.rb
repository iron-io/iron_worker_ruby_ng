require_relative 'runtime/python'

module IronWorkerNG
  module Code
    class Python < IronWorkerNG::Code::Base
      def initialize(*args, &block)
        runtime(:python)

        super(*args, &block)
      end
    end
  end
end
