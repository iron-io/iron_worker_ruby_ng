module IronWorkerNG
  module Feature
    module Python
      module MergePipDependency
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :name
          attr_reader :version

          def initialize(code, name, version)
            super(code)

            @name = name
            @version = version
          end

          def build_command
            if @code.full_remote_build
              "pip '#{@name}', '#{@version}'"
            elsif @code.remote_build_command
              "dir '__build__/__pips__'"
            else
              nil
            end
          end
        end

        module InstanceMethods
          def merge_pip(name, version = '')
            IronCore::Logger.info 'IronWorkerNG', "Adding python pip dependency with name='#{name}' and version='#{version}'"

            @features << IronWorkerNG::Feature::Python::MergePipDependency::Feature.new(self, name, version)

            unless @fixators.include?(:merge_pip_dependency_fixate)
              @fixators << :merge_pip_dependency_fixate
            end
          end

          alias :pip :merge_pip

          def merge_pip_dependency_fixate
            if not full_remote_build
              IronCore::Logger.info 'IronWorkerNG', 'Fixating pip dependencies'

              @features.reject! { |f| f.class == IronWorkerNG::Feature::Python::MergePip::Feature }

              deps = @features.reject { |f| f.class != IronWorkerNG::Feature::Python::MergePipDependency::Feature }

              @features << IronWorkerNG::Feature::Python::MergePip::Feature.new(self, deps)
            end
          end
        end
      end
    end
  end
end
