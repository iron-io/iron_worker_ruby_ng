module IronWorkerNG
  module Feature
    module Java
      module MergeExec
        class Feature < IronWorkerNG::Feature::Common::MergeExec::Feature
          attr_accessor :klass

          def code_for_classpath
            File.basename(@path)
          end
        end

        module InstanceMethods
          def merge_exec(path = nil, klass = nil)
            IronCore::Logger.info 'IronWorkerNG', "Executable class is '#{klass}'" if klass
            super(path, klass)
          end

          alias :exec :merge_exec

          alias :merge_worker :merge_exec
          alias :worker :merge_worker
        end
      end
    end
  end
end
