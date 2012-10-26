module IronWorkerNG
  module Feature
    module Java
      module MergeJar
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path

          def initialize(code, path)
            super(code)

            @path = path
          end

          def bundle(container)
            IronCore::Logger.debug 'IronWorkerNG', "Bundling java jar with path='#{@path}'"

            if (not @code.full_remote_build) || (not IronWorkerNG::Fetcher.remote?(rebase(@path)))
              container_add(container, File.basename(@path), rebase(@path))
            end
          end

          def build_command
            if @code.remote_build_command || @code.full_remote_build
              if @code.full_remote_build && IronWorkerNG::Fetcher.remote?(rebase(@path))
                "jar '#{rebase(@path)}'"
              else
                "jar '#{@code.dest_dir}#{File.basename(@path)}'"
              end
            else
              nil
            end
          end

          def code_for_classpath
            File.basename(@path)
          end
        end

        module InstanceMethods
          def merge_jar(path)
            IronCore::Logger.info 'IronWorkerNG', "Merging java jar with path='#{path}'"

            @features << IronWorkerNG::Feature::Java::MergeJar::Feature.new(self, path)
          end

          alias :jar :merge_jar
        end
      end
    end
  end
end
