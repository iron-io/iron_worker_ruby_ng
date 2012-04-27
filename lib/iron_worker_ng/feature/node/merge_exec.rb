module IronWorkerNG
  module Feature
    module Node
      module MergeExec
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path

          def initialize(path)
            @path = File.expand_path(path)
          end

          def hash_string
            Digest::MD5.hexdigest(@path + File.mtime(@path).to_i.to_s)
          end

          def bundle(zip)
            IronCore::Logger.debug 'IronWorkerNG', "Bundling node exec with path='#{@path}'"

            zip.add(File.basename(@path), @path)
          end
        end

        module InstanceMethods
          def merge_exec(path)
            @exec ||= nil 

            unless @exec.nil?
              IronCore::Logger.warn 'IronWorkerNG', "Ignoring attempt to merge node exec with path='#{path}'"
              return
            end

            @name ||= File.basename(path).gsub(/\.js$/, '').capitalize.gsub(/_./) { |x| x[1].upcase }

            @exec = IronWorkerNG::Feature::Node::MergeExec::Feature.new(path)

            IronCore::Logger.info 'IronWorkerNG', "Merging node exec with path='#{path}'"

            @features << @exec
          end

          alias :exec :merge_exec

          alias :merge_worker :merge_exec
          alias :worker :merge_worker

          def self.included(base)
            IronWorkerNG::Code::Base.register_feature(:name => 'merge_exec', :for_klass => base, :args => 'PATH')
          end
        end
      end
    end
  end
end
