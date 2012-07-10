require_relative '../../feature/go/merge_exec'

module IronWorkerNG
  module Code
    module Runtime
      module Go
        include IronWorkerNG::Feature::Go::MergeExec::InstanceMethods

        def runtime_run_code
          <<RUN_CODE
go run #{File.basename(@exec.path)} "$@"
RUN_CODE
        end
      end
    end
  end
end
