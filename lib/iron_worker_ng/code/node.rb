require File.expand_path('runtime/node', File.dirname(__FILE__))

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
