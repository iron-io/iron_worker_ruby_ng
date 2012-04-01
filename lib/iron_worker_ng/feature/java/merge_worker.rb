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
            logger.debug "Bundling worker #{@path}"
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
              logger.warn "Ignoring attempt to merge another worker #{path}"
              return
            end

            @name ||= klass.split('.')[-1]

            @worker = IronWorkerNG::Feature::Java::MergeWorker::Feature.new(path, klass)
            logger.debug "Merging worker #{@name}"
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
