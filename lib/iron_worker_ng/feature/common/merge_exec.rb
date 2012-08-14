module IronWorkerNG
  module Feature
    module Common
      module MergeExec
        class Feature < IronWorkerNG::Feature::Base
          attr_accessor :path

          def initialize(code, path = nil, klass = nil)
            super(code)
            @path = path
            if klass
              @klass = klass 
              class << self
                attr_accessor :klass
              end
            end
          end

          def hash_string
            Digest::MD5.hexdigest(@path + (@klass || '') +
                                  File.mtime(rebase(@path)).to_i.to_s)
          end

          def bundle(container)
            msg = "Bundling #{@code.runtime} exec with path='#{@path}'"
            msg += "and class='#{@klass}'" if @klass
            IronCore::Logger.debug 'IronWorkerNG', msg

            container_add(container, File.basename(@path), @path)
          end
        end

        module InstanceMethods
          def merge_exec(path=nil, *rest)
            unless runtime
              runtime 'ruby'
              return merge_exec(path, *rest)
            end

            @exec ||= nil

            return @exec unless path

            if @exec
              IronCore::Logger.warn('IronWorkerNG',
                                    "Ignoring attempt to merge another " +
                                    "#{runtime} exec, with path='#{path}'")
              return
            end

            path = base_dir + path

            exec_path, clean = IronWorkerNG::Fetcher.fetch(path, true)
            IronCore::Logger.error('IronWorkerNG',
                                   "File not found: '#{path}'",
                                   IronCore::Error) unless
              exec_path and File.file?(exec_path)

            if clean
              ObjectSpace.define_finalizer self, proc{ FileUtils.rm_f(clean) }
            end

            @exec = IronWorkerNG::Feature.
              const_get(runtime).
              const_get('MergeExec').
              const_get('Feature').new(self, exec_path, *rest)

            IronCore::Logger.info 'IronWorkerNG', "Detected #{runtime} exec with path='#{path}'"

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
