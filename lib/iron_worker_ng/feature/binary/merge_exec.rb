module IronWorkerNG
  module Feature
    module Binary
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

          def bundle(container)
            IronCore::Logger.debug 'IronWorkerNG', "Bundling binary exec with path='#{@path}'"

            container_add(container, File.basename(@path), rebase(@path))
          end
        end

        module InstanceMethods
          def merge_exec(path=nil)
            @exec ||= nil

            return @exec unless path

            unless @exec.nil?
              IronCore::Logger.warn 'IronWorkerNG', "Ignoring attempt to merge binary exec with path='#{path}'"
              return
            end

            @exec = IronWorkerNG::Feature::Binary::MergeExec::Feature.new(self, path)

            IronCore::Logger.info 'IronWorkerNG', "Merging binary exec with path='#{path}'"

            @features << @exec
          end

          alias :exec :merge_exec

          alias :merge_worker :merge_exec
          alias :worker :merge_worker
        end
      end
    end
  end
end
