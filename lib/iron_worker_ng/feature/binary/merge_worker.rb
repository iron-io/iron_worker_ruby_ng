module IronWorkerNG
  module Feature
    module Binary
      module MergeWorker
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path

          def initialize(path)
            @path = File.expand_path(path)
          end

          def hash_string
            Digest::MD5.hexdigest(@path + File.mtime(@path).to_i.to_s)
          end

          def bundle(zip)
            IronWorkerNG::Logger.debug "Bundling binary worker with path='#{@path}'"

            zip.add(File.basename(@path), @path)
          end
        end

        module InstanceMethods
          attr_reader :worker

          def merge_worker(path)
            @worker ||= nil 

            unless @worker.nil?
              IronWorkerNG::Logger.warn "Ignoring attempt to merge binary worker with path='#{path}'"
              return
            end

            @name ||= File.basename(path).gsub(/\.js$/, '').capitalize.gsub(/_./) { |x| x[1].upcase }

            @worker = IronWorkerNG::Feature::Binary::MergeWorker::Feature.new(path)

            IronWorkerNG::Logger.info "Merging binary worker with path='#{path}'"

            @features << @worker
          end

          def self.included(base)
            IronWorkerNG::Code::Base.register_feature(:name => 'merge_worker', :for_klass => base, :args => 'PATH')
          end
        end
      end
    end
  end
end
