module IronWorkerNG
  module Feature
    module Common
      module MergeExec
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path
          attr_reader :args

          def initialize(code, path, args)
            super(code)

            @path = path
            @args = args
          end

          def arg(name, i = nil)
            if @args.is_a?(Hash)
              return @args[name.to_sym] || @args[name.to_s]
            elsif @args.is_a?(Array) && (not i.nil?)
              return @args[i]
            end

            nil
          end

          def hash_string
            Digest::MD5.hexdigest(@path + File.mtime(rebase(@path)).to_i.to_s + args.to_s)
          end

          def bundle(container)
            IronCore::Logger.debug 'IronWorkerNG', "Bundling exec with path='#{@path}' and args='#{@args.inspect}'"

            container_add(container, File.basename(@path), rebase(@path))
          end
        end

        module InstanceMethods
          def merge_exec(path, args = {})
            @exec ||= nil

            if (not args.is_a?(Hash)) && (not args.is_a?(Array))
              args = [args]
            end

            unless @exec.nil?
              IronCore::Logger.warn 'IronWorkerNG', "Ignoring attempt to merge exec with path='#{path}' and args='#{args.inspect}'"
              return
            end

            @exec = IronWorkerNG::Feature::Common::MergeExec::Feature.new(self, path, args)

            IronCore::Logger.info 'IronWorkerNG', "Detected exec with path='#{path}' and args='#{args.inspect}'"

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
