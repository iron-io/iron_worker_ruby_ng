module IronWorkerNG
  module Feature
    module Ruby
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

          def code_for_init
            "worker_file_name = '#{File.basename(@path)}'\nworker_class_name='#{@klass}'"
          end
        end

        module InstanceMethods
          attr_reader :worker

          def merge_worker(path, klass = nil)
            @worker ||= nil 

            unless @worker.nil?
              logger.warn "Ignoring attempt to merge another worker #{path}"
              return
            end

            if klass == nil
              klass = File.basename(path).gsub(/\.rb$/, '').capitalize.gsub(/_./) { |x| x[1].upcase }
            end

            @name ||= klass

            @worker = IronWorkerNG::Feature::Ruby::MergeWorker::Feature.new(path, klass)
            logger.debug "Merging worker #{@name}"
            @features << @worker
          end

          def self.included(base)
            IronWorkerNG::Code::Base.register_feature(:name => 'merge_worker', :for_klass => base, :args => 'PATH[,CLASS]')
          end
        end
      end
    end
  end
end
