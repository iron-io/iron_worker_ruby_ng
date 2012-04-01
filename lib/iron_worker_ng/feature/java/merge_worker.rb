module IronWorkerNG
  module Feature
    module Java
      module MergeWorker
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path
          attr_reader :klass

          def initialize(path, klass)
            @path = File.expand_path(path)
            @klass = klass
          end

          def hash_string
            Digest::MD5.hexdigest(@path + @klass + File.mtime(@path).to_i.to_s)
          end

          def bundle(zip)
            IronWorkerNG::Logger.info "Bundling java worker with #{@path} path and #{@klass} class"

            zip.add(File.basename(@path), @path)
          end

          def code_for_classpath
            File.basename(@path)
          end
        end

        module InstanceMethods
          attr_reader :worker

          def merge_worker(path, klass)
            @worker ||= nil 

            unless @worker.nil?
              IronWorkerNG::Logger.warn "Ignoring attempt to merge java worker with #{path} path"
              return
            end

            @name ||= klass.split('.')[-1]

            @worker = IronWorkerNG::Feature::Java::MergeWorker::Feature.new(path, klass)

            IronWorkerNG::Logger.info "Merging java worker with #{path} path and #{klass} class"

            @features << @worker
          end

          def self.included(base)
            IronWorkerNG::Code::Base.register_feature(:name => 'merge_worker', :for_klass => base, :args => 'PATH,CLASS')
          end
        end
      end
    end
  end
end
