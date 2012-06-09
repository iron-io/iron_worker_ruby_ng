module IronWorkerNG
  module Feature
    class Base
      def initialize(code)
        @code = code
      end

      def rebase(path)
        if not path.start_with?('/')
          path = @code.base_dir + path
        end

        path
      end

      def zip_add(zip, dest, src)
        src = File.expand_path(src)

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
