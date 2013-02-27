require File.expand_path('runtime/perl', File.dirname(__FILE__))

module IronWorkerNG
  module Code
    class Perl < IronWorkerNG::Code::Base
      def initialize(*args, &block)
        runtime(:perl)

        super(*args, &block)
      end
    end
  end
end
