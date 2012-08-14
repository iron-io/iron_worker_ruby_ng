require_relative '../../feature/perl/merge_exec'

module IronWorkerNG
  module Code
    module Runtime
      module Perl
        def runtime_run_code(local = false)
          <<RUN_CODE
perl #{File.basename(@exec.path)} "$@"
RUN_CODE
        end
      end
    end
  end
end
