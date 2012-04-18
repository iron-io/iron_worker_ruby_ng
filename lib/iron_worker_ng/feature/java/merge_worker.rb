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
            IronWorkerNG::Logger.debug "Bundling java worker with path='#{@path}' and class='#{@klass}'"

            zip.add(File.basename(@path), @path)
          end

          def code_for_classpath
            File.basename(@path)
          end
        end

        module InstanceMethods
          attr_reader :worker

          def merge_worker(path, klass = nil)
            @worker ||= nil 

            unless @worker.nil?
              IronWorkerNG::Logger.warn "Ignoring attempt to merge java worker with path='#{path}' and class='#{klass}'"
              return
            end

            if klass.nil?
              @name ||= File.basename(path).gsub(/\.jar$/, '').capitalize.gsub(/_./) { |x| x[1].upcase }
            else
              @name ||= klass.split('.')[-1]
            end

            @worker = IronWorkerNG::Feature::Java::MergeWorker::Feature.new(path, klass)

            IronWorkerNG::Logger.info "Merging java worker with path='#{path}' and class='#{klass}'"

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
