module IronWorkerNG
  module Feature
    module Common
      module SetEnv
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :key
          attr_reader :value

          def initialize(code, key, value)
            super(code)

            @key = key
            @value = value
          end

          def bundle(container)
            container.runner_add "export #{@key}=\"#{@value.to_s.gsub('"','\\"')}\""
          end

          def build_command
            if @code.remote_build_command || @code.full_remote_build
              "set_env \"#{@key}\", \"#{@value.to_s.gsub('"','\\"')}\""
            else
              nil
            end
          end
        end

        module InstanceMethods
          def set_env(key, value)
            IronCore::Logger.info 'IronWorkerNG', "Setting ENV variable with name='#{key}' and value='#{@value}'"

            @features << IronWorkerNG::Feature::Common::SetEnv::Feature.new(self, key, value)
          end
        end
      end
    end
  end
end
