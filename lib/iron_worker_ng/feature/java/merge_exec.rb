module IronWorkerNG
  module Feature
    module Java
      module MergeExec
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path
          attr_reader :klass

          def initialize(code, path, klass)
            super(code)

            @path = path
            @klass = klass
          end

          def hash_string
            Digest::MD5.hexdigest(@path + @klass + File.mtime(rebase(@path)).to_i.to_s)
          end

          def bundle(container)
            IronCore::Logger.debug 'IronWorkerNG', "Bundling java exec with path='#{@path}' and class='#{@klass}'"

            container_add(container, File.basename(@path), rebase(@path))
          end

          def code_for_classpath
            File.basename(@path)
          end
        end

        module InstanceMethods
          def merge_exec(path = nil, klass = nil)
            @exec ||= nil

            return @exec unless path

            unless @exec.nil?
              IronCore::Logger.warn 'IronWorkerNG', "Ignoring attempt to merge java exec with path='#{path}' and class='#{klass}'"
              return
            end

            @exec = IronWorkerNG::Feature::Java::MergeExec::Feature.new(self, path, klass)

            IronCore::Logger.info 'IronWorkerNG', "Merging java exec with path='#{path}' and class='#{klass}'"

            @features << @exec
          end

          alias :exec :merge_exec

          alias :merge_worker :merge_exec
          alias :worker :merge_worker
        end
      end
    end
  end
end
