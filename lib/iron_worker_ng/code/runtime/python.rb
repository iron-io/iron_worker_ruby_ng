require File.expand_path('../../feature/python/merge_pip_dependency', File.dirname(__FILE__))
require File.expand_path('../../feature/python/merge_pip', File.dirname(__FILE__))

module IronWorkerNG
  module Code
    module Runtime
      module Python
        include IronWorkerNG::Feature::Common::MergeExec::InstanceMethods
        include IronWorkerNG::Feature::Python::MergePipDependency::InstanceMethods

        def runtime_run_code(local = false)
          <<RUN_CODE
PATH=`pwd`/__pips__/bin:$PATH PYTHONPATH=`pwd`/__pips__ python -u #{File.basename(@exec.path)} "$@"
RUN_CODE
        end
      end
    end
  end
end
