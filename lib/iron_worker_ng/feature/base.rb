module IronWorkerNG
  module Feature
    class Base
      def initialize(code)
        @code = code
      end

      def hash_string
        ''
      end

      def bundle(zip)
      end
    end
  end
end
