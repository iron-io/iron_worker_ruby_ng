require_relative 'runtime/perl'

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
