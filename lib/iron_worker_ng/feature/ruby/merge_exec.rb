module IronWorkerNG
  module Feature
    module Ruby
      module MergeExec
        class Feature < IronWorkerNG::Feature::Common::MergeExec::Feature
          attr_accessor :klass
        end

        module InstanceMethods
          def merge_exec(path = nil, klass = nil)
            super(path, klass)
            IronCore::Logger.info 'IronWorkerNG', "Executable class is '#{klass}'"
          end

          alias :exec :merge_exec

          alias :merge_worker :merge_exec
          alias :worker :merge_worker
        end
      end
    end
  end
end
