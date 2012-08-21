require_relative '../../feature/node/merge_exec'

module IronWorkerNG
  module Code
    module Runtime
      module Node
        include IronWorkerNG::Feature::Node::MergeExec::InstanceMethods

        def runtime_run_code(local = false)
          <<RUN_CODE
node #{File.basename(@exec.path)} "$@"
RUN_CODE
        end
      end
    end
  end
end
