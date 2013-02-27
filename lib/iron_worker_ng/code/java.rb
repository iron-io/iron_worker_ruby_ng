require File.expand_path('runtime/java', File.dirname(__FILE__))

module IronWorkerNG
  module Code
    class Java < IronWorkerNG::Code::Base
      def initialize(*args, &block)
        runtime(:java)

        super(*args, &block)
      end
    end
  end
end
