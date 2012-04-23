module IronWorkerNG
  module Feature
    module Ruby
      module MergeExec
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path
          attr_reader :klass

          def initialize(path, klass)
            @path = File.expand_path(path)
            @klass = klass
          end

          def hash_string
            Digest::MD5.hexdigest(@path + @klass + File.mtime(@path).to_i.to_s)
          end

          def bundle(zip)
            IronWorkerNG::Logger.debug "Bundling ruby exec with path='#{path}' and class='#{klass}'"

            zip.add(File.basename(@path), @path)
          end
        end

        module InstanceMethods
          attr_reader :exec

          def merge_exec(path, klass = nil)
            @exec ||= nil 

            if klass == nil
              klass = File.basename(path).gsub(/\.rb$/, '').capitalize.gsub(/_./) { |x| x[1].upcase }
            end

            unless @exec.nil?
              IronWorkerNG::Logger.warn "Ignoring attempt to merge ruby exec with path='#{path}' and class='#{klass}'"
              return
            end

            @name ||= klass

            @exec = IronWorkerNG::Feature::Ruby::MergeExec::Feature.new(path, klass)

            IronWorkerNG::Logger.info "Merging ruby exec with path='#{path}' and class='#{klass}'"

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
