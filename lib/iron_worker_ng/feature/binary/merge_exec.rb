module IronWorkerNG
  module Feature
    module Binary
      module MergeExec
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path

          def initialize(path)
            unless File.exist?(path)
              IronCore::Logger.error 'IronWorkerNG', "Can't find binary exec with path='#{path}'"
              raise IronCore::IronError.new("Can't find binary exec with path='#{path}'")
            end

            @path = File.expand_path(path)
          end

          def hash_string
            Digest::MD5.hexdigest(@path + File.mtime(@path).to_i.to_s)
          end

          def bundle(zip)
            IronCore::Logger.debug 'IronWorkerNG', "Bundling binary exec with path='#{@path}'"

            zip.add(File.basename(@path), @path)
          end
        end

        module InstanceMethods
          def merge_exec(path)
            @exec ||= nil 

            unless @exec.nil?
              IronCore::Logger.warn 'IronWorkerNG', "Ignoring attempt to merge binary exec with path='#{path}'"
              return
            end

            @exec = IronWorkerNG::Feature::Binary::MergeExec::Feature.new(path)

            IronCore::Logger.info 'IronWorkerNG', "Merging binary exec with path='#{path}'"

            @features << @exec

            guess_name
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
