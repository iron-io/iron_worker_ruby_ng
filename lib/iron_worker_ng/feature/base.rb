require 'fileutils'

module IronWorkerNG
  module Feature
    class Base
      def initialize(code)
        @code = code
      end

      def rebase(path)
        @code.base_dir + path
      end

      def zip_add(zip, dest, src)
        new_src, clean = IronWorkerNG::Fetcher.fetch(src, true)

        new_src = File.expand_path(new_src) unless new_src.nil?

        if new_src.nil? || (not File.exists?(new_src))
          IronCore::Logger.error 'IronWorkerNG', "Can't find src with path='#{src}'", IronCore::Error
        end

        src = new_src

        if File.directory?(src)
          Dir.glob(src + '/**/**') do |path|
            zip.add(@code.dest_dir + dest + path[src.length .. -1], path)
          end
        else
          zip.add(@code.dest_dir + dest, src)
        end

        unless clean.nil?
          FileUtils.rm_f(clean)
        end
      end

      def hash_string
        ''
      end

      def bundle(zip)
      end
    end
  end
end
