module IronWorkerNG
  module Feature
    module Node
      module MergeExec
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path

          def initialize(code, path)
            super(code)

            @path = path
          end

          def hash_string
            Digest::MD5.hexdigest(@path + File.mtime(rebase(@path)).to_i.to_s)
          end

          def bundle(zip)
            IronCore::Logger.debug 'IronWorkerNG', "Bundling node exec with path='#{@path}'"

            zip_add(zip, File.basename(@path), rebase(@path))
          end
        end

        module InstanceMethods
          def merge_exec(path=nil)
            @exec ||= nil 

            return @exec unless path

            unless @exec.nil?
              IronCore::Logger.warn 'IronWorkerNG', "Ignoring attempt to merge node exec with path='#{path}'"
              return
            end

            @exec = IronWorkerNG::Feature::Node::MergeExec::Feature.new(self, path)

            IronCore::Logger.info 'IronWorkerNG', "Merging node exec with path='#{path}'"

            @features << @exec
          end

          alias :exec :merge_exec

          alias :merge_worker :merge_exec
          alias :worker :merge_worker

          def self.included(base)
            IronWorkerNG::Code.register_feature(:name => 'merge_exec', :for_klass => base, :args => 'PATH')
          end
        end
      end
    end
  end
end
