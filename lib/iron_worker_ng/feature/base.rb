module IronWorkerNG
  module Feature
    class Base
      def initialize(code)
        @code = code
      end

      def zip_add(zip, dest, src)
        zip.add(dest, src)
      end

      def hash_string
        ''
      end

      def bundle(zip)
      end
    end
  end
end
