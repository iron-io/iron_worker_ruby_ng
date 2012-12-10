require 'tmpdir'
require 'pathname'

module IronWorkerNG
  module Code
    module Container
      class Base
        attr_reader :name

        def initialize
          @name = ::Dir.tmpdir + '/' + ::Dir::Tmpname.make_tmpname('iron-worker-ng-', 'container')
        end

        def clear_dest(dest)
          dest = Pathname.new(dest).cleanpath.to_s unless dest.empty?

          dest
        end

        def add(dest, src)
        end

        def get_output_stream(dest, &block)
        end

        def commit
        end

        def close
        end
      end
    end
  end
end
