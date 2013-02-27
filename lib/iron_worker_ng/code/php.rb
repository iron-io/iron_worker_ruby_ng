require File.expand_path('runtime/php', File.dirname(__FILE__))

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
