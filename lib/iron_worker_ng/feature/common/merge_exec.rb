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

          def bundle(container)
            IronCore::Logger.debug 'IronWorkerNG', "Bundling exec with path='#{@path}' and args='#{@args.inspect}'"

            if (not @code.full_remote_build) || (not IronWorkerNG::Fetcher.remote?(rebase(@path)))
              container_add(container, File.basename(@path), rebase(@path))
            end
          end

          def build_command
            if @code.remote_build_command || @code.full_remote_build
              if @code.full_remote_build && IronWorkerNG::Fetcher.remote?(rebase(@path))
                "exec '#{rebase(@path)}', #{@args.inspect}"
              else
                "exec '#{@code.dest_dir}#{File.basename(@path)}', #{@args.inspect}"
              end
            else
              nil
            end
          end
        end

        module InstanceMethods
          def merge_exec(path = nil, args = {})
            @exec ||= nil

            return @exec unless path

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
