module IronWorkerNG
  module Feature
    module Java
      module MergeExec
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path
          attr_reader :klass

          def initialize(code, path, klass)
            super(code)

            unless File.exist?(path)
              IronCore::Logger.error 'IronWorkerNG', "Can't find java exec with path='#{path}'"
              raise IronCore::IronError.new("Can't find java exec with path='#{path}'")
            end

            @path = File.expand_path(path)
            @klass = klass
          end

          def hash_string
            Digest::MD5.hexdigest(@path + @klass + File.mtime(@path).to_i.to_s)
          end

          def bundle(zip)
            IronCore::Logger.debug 'IronWorkerNG', "Bundling java exec with path='#{@path}' and class='#{@klass}'"

            zip_add(zip, File.basename(@path), @path)
          end

          def code_for_classpath
            File.basename(@path)
          end
        end

        module InstanceMethods
          def merge_exec(path, klass = nil)
            @exec ||= nil 

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

          def self.included(base)
            IronWorkerNG::Code::Base.register_feature(:name => 'merge_exec', :for_klass => base, :args => 'PATH,CLASS')
          end
        end
      end
    end
  end
end
