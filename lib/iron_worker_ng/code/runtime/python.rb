module IronWorkerNG
  module Code
    module Runtime
      module Python
        include IronWorkerNG::Feature::Common::MergeExec::InstanceMethods

        def runtime_run_code(local = false)
          <<RUN_CODE
python #{File.basename(@exec.path)} "$@"
RUN_CODE
        end
      end
    end
  end
end
