require 'zip/zip'

module IronWorkerNG
  module Code
    module Container
      class Zip < IronWorkerNG::Code::Container::Base
        def initialize
          super

          @name = @name + '.zip'
          @zip = ::Zip::ZipFile.open(@name, ::Zip::ZipFile::CREATE)
        end

        def add(dest, src)
          @zip.add(clear_dest(dest), src)
        end

        def get_output_stream(dest, &block)
          @zip.get_output_stream(clear_dest(dest), &block)
        end

        def close
          @zip.close
        end
      end
    end
  end
end
