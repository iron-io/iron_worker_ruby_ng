require_relative '../../feature/python/merge_exec'

module IronWorkerNG
  module Code
    module Runtime
      module Python
        include IronWorkerNG::Feature::Python::MergeExec::InstanceMethods

        def runtime_run_code
          <<RUN_CODE
python #{File.basename(@exec.path)} "$@"
RUN_CODE
        end
      end
    end
  end
end
