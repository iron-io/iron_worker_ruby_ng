module IronWorkerNG
  module Feature
    class Base
      def initialize(code)
        @code = code
      end

      def zip_add(zip, dest, src, rebase = true)
        if rebase && (not src.start_with?('/'))
          src = @code.base_dir + src
        end

        unless File.exists?(src)
          IronCore::Logger.error 'IronWorkerNG', "Can't find src with path='#{src}'"
          raise IronCore::IronError.new("Can't find src with path='#{src}'")
        end

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
