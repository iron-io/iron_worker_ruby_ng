require_relative '../../feature/python/merge_pip_dependency'
require_relative '../../feature/python/merge_pip'

module IronWorkerNG
  module Code
    module Runtime
      module Python
        include IronWorkerNG::Feature::Common::MergeExec::InstanceMethods
        include IronWorkerNG::Feature::Python::MergePipDependency::InstanceMethods

        def runtime_run_code(local = false)
          <<RUN_CODE
PYTHONPATH=`pwd`/__pips__ python #{File.basename(@exec.path)} "$@"
RUN_CODE
        end
      end
    end
  end
end
