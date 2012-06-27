require_relative '../feature/node/merge_exec'

module IronWorkerNG
  module Runtime
    module Node
      include IronWorkerNG::Feature::Node::MergeExec::InstanceMethods

      def run_code
        <<RUN_CODE
node #{File.basename(@exec.path)} "$@"
RUN_CODE
      end
    end
  end
end

IronWorkerNG::Code.register_type(:name => 'node', :klass => IronWorkerNG::Runtime::Node)
