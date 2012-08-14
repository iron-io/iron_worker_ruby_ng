module IronWorkerNG
  module Feature
    module Perl
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
            IronCore::Logger.debug 'IronWorkerNG', "Bundling perl exec with path='#{@path}'"

            container_add(container, File.basename(@path), rebase(@path))
          end
        end

        module InstanceMethods
          def merge_exec(path=nil)
            @exec ||= nil

            return @exec unless path

            unless @exec.nil?
              IronCore::Logger.warn 'IronWorkerNG', "Ignoring attempt to merge perl exec with path='#{path}'"
              return
            end

            IronCore::Logger.error('IronWorkerNG',
                                   "File not found: '#{@base_dir + path}'",
                                   IronCore::Error) unless
              File.file?(@base_dir + path)

            @exec = IronWorkerNG::Feature::Perl::MergeExec::Feature.new(self, path)

            IronCore::Logger.info 'IronWorkerNG', "Detected perl exec with path='#{path}'"

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
