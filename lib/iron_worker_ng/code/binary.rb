require_relative 'runtime/binary'

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
