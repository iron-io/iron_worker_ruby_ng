module IronWorkerNG
  module Feature
    class Base
      def initialize(code)
        @code = code
      end

      def rebase(path)
        @code.base_dir + path
      end

      def container_add(container, dest, src)
        IronWorkerNG::Fetcher.fetch_to_file(src) do |local_src|
          if local_src.nil? || (not File.exists?(local_src))
            IronCore::Logger.error 'IronWorkerNG', "Can't find src with path='#{src}'", IronCore::Error
          end

          if File.directory?(local_src)
            ::Dir.glob(local_src + '/**/**') do |path|
              container.add(@code.dest_dir + dest + path[local_src.length .. -1], path)
            end
          else
            container.add(@code.dest_dir + dest, local_src)
          end
        end
      end

      def hash_string
        ''
      end

      def bundle(container)
      end

      def command(remote = false)
        nil
      end
    end
  end
end
