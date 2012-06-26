require_relative 'initializer'
require_relative 'base'
require_relative 'ruby'
require_relative 'java'
require_relative 'node'
require_relative 'binary'
require_relative 'builder'

module IronWorkerNG
  module Code
    class Creator
      include IronWorkerNG::Code::Initializer::InstanceMethods

      def self.create(*args, &block)
        runtime = IronWorkerNG::Code::Creator.new(*args, &block).runtime || 'ruby'

        IronWorkerNG::Code::Base.registered_types.find { |r| r[:name] == runtime }[:klass].new(*args, &block)
      end

      def initialize(*args, &block)
        initialize_code(*args, &block)
      end

      def name(name = nil)
        @name = name if name

        @name
      end

      def name=(name)
        @name = name
      end

      def remote_build_command(remote_build_command = nil)
      end

      def remote_build_command=(remote_build_command)
      end

      def runtime(*args)
        @runtime = args[0] if args.length == 1

        @runtime
      end

      def runtime=(runtime)
        @runtime = runtime
      end

      def merge_exec(path, *args)
        @exec = OpenStruct.new(:path => path)
      end

      alias :exec :merge_exec

      alias :merge_worker :merge_exec
      alias :worker :merge_worker

      def method_missing(name, *args)
      end
    end
  end
end
