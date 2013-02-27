require File.expand_path('runtime/mono', File.dirname(__FILE__))

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
