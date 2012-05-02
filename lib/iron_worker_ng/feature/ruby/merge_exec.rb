module IronWorkerNG
  module Feature
    module Ruby
      module MergeExec
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path
          attr_reader :klass

          def initialize(path, klass)
            unless File.exist?(path)
              IronCore::Logger.error 'IronWorkerNG', "Can't find ruby exec with path='#{path}'"
              raise IronCore::IronError.new("Can't find ruby exec with path='#{path}'")
            end

            @path = File.expand_path(path)
            @klass = klass
          end

          def hash_string
            Digest::MD5.hexdigest(@path + @klass + File.mtime(@path).to_i.to_s)
          end

          def bundle(zip)
            IronCore::Logger.debug 'IronWorkerNG', "Bundling ruby exec with path='#{path}' and class='#{klass}'"

            zip.add(File.basename(@path), @path)
          end
        end

        module InstanceMethods
          def merge_exec(path, klass = nil)
            @exec ||= nil 

            if klass == nil
              klass = File.basename(path).gsub(/\.rb$/, '').capitalize.gsub(/_./) { |x| x[1].upcase }
            end

            unless @exec.nil?
              IronCore::Logger.warn 'IronWorkerNG', "Ignoring attempt to merge ruby exec with path='#{path}' and class='#{klass}'"
              return
            end

            @name ||= klass

            @exec = IronWorkerNG::Feature::Ruby::MergeExec::Feature.new(path, klass)

            IronCore::Logger.info 'IronWorkerNG', "Merging ruby exec with path='#{path}' and class='#{klass}'"

            @features << @exec
          end

          alias :exec :merge_exec

          alias :merge_worker :merge_exec
          alias :worker :merge_worker

          def self.included(base)
            IronWorkerNG::Code::Base.register_feature(:name => 'merge_exec', :for_klass => base, :args => 'PATH[,CLASS]')
          end
        end
      end
    end
  end
end
