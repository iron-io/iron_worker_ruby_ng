require 'fileutils'

module IronWorkerNG
  module Code
    class DirContainer
      def initialize(dir)
        @dir = dir
      end

      def full_dest(dest)
        @dir + '/' + dest
      end

      def add(dest, src)
        FileUtils.mkdir_p(File.dirname(full_dest(dest)))

        if File.directory?(src)
          FileUtils.mkdir(full_dest(dest))
        else
          FileUtils.cp(src, full_dest(dest))
        end
      end

      def get_output_stream(dest, &block)
        FileUtils.mkdir_p(File.dirname(full_dest(dest)))

        file = File.open(full_dest(dest), 'wb')
        yield file
        file.close
      end
    end
  end
end
