module IronWorkerNG
  module Features
    module Ruby
      class WorkerMerger < IronWorkerNG::Features::Feature
        attr_reader :path
        attr_reader :name

        def initialize(path, name)
          @path = File.expand_path(path)
          @name = name
        end

        def hash_string
          Digest::MD5.hexdigest(@path + @name)
        end

        def bundle(zip)
          zip.add('./' + File.basename(@path), @path)
        end

        def code_for_init
          "worker_file_name = '#{File.basename(@path)}'\nworker_class_name='#{@name}'"
        end
      end

      module InstanceMethods
        attr_reader :worker

        def merge_worker(path, name = nil)
          @features ||= []
          @worker ||= nil 

          return unless @worker.nil?

          if name == nil
            name = File.basename(path).gsub(/\.rb$/, '').capitalize.gsub(/_./) { |x| x[1].upcase }
          end

          @name ||= name

          @worker = IronWorkerNG::Features::Ruby::WorkerMerger.new(path, name)
          @features << @worker
        end
      end
    end
  end
end

IronWorkerNG::Features.register_feature_method('merge_worker')
