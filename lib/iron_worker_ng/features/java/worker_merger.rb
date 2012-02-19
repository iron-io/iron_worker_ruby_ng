module IronWorkerNG
  module Features
    module Java
      class WorkerMerger < IronWorkerNG::Features::Feature
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
          zip.add(File.basename(@path), @path)
        end

        def code_for_classpath
          File.basename(@path)
        end
      end

      module InstanceMethods
        attr_reader :worker

        def merge_worker(path, klass)
          @features ||= []
          @worker ||= nil 

          return unless @worker.nil?

          @name ||= klass.split('.')[-1]

          @worker = IronWorkerNG::Features::Java::WorkerMerger.new(path, klass)
          @features << @worker
        end
      end
    end
  end
end

IronWorkerNG::Features.register_feature_method('merge_worker')
