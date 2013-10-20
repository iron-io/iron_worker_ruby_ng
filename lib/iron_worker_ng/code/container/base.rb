require 'tmpdir'
require 'pathname'

module IronWorkerNG
  module Code
    module Container
      class Base
        attr_reader :name
        attr_reader :runner_additions

        def initialize
          @name = ::Dir.tmpdir + '/' + ::Dir::Tmpname.make_tmpname('iron-worker-ng-', 'container')
          @runner_additions = ''
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

        def runner_add(runner_code)
          @runner_additions << runner_code << "\n"
        end
      end
    end
  end
end
