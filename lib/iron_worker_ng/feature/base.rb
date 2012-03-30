module IronWorkerNG
  module Feature
    class Base
      def logger
        IronWorkerNG.logger
      end

      def hash_string
        ''
      end

      def bundle(zip)
      end
    end
  end
end
