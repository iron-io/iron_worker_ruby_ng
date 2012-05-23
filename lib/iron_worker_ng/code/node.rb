require_relative '../feature/node/merge_exec'

module IronWorkerNG
  module Code
    class Node < IronWorkerNG::Code::Base
      include IronWorkerNG::Feature::Node::MergeExec::InstanceMethods

      def run_code
        <<RUN_CODE
node #{File.basename(@exec.path)} "$@"
RUN_CODE
      end
    end
  end
end

IronWorkerNG::Code::Base.register_type(:name => 'node', :klass => IronWorkerNG::Code::Node)
