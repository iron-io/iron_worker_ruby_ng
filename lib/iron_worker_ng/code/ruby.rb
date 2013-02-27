require File.expand_path('runtime/ruby', File.dirname(__FILE__))

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
