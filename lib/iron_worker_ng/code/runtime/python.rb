require 'iron_worker_ng/feature/python/merge_pip_dependency'
require 'iron_worker_ng/feature/python/merge_pip'

module IronWorkerNG
  module Code
    module Runtime
      module Python
        include IronWorkerNG::Feature::Common::MergeExec::InstanceMethods
        include IronWorkerNG::Feature::Python::MergePipDependency::InstanceMethods

        def runtime_run_code(local = false)
          <<RUN_CODE
PATH=`pwd`/__pips__/__bin__:$PATH PYTHONPATH=`pwd`/__pips__ python -u #{File.basename(@exec.path)} "$@"
RUN_CODE
        end
      end
    end
  end
end
