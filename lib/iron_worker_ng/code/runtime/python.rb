require_relative '../../feature/python/merge_exec'

module IronWorkerNG
  module Code
    module Runtime
      module Python
        def runtime_run_code(local = false)
          <<RUN_CODE
python #{File.basename(@exec.path)} "$@"
RUN_CODE
        end
      end
    end
  end
end
