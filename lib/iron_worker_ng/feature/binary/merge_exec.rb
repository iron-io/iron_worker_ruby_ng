module IronWorkerNG
  module Feature
    module Binary
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
            IronWorkerNG::Logger.debug "Bundling binary exec with path='#{@path}'"

            zip.add(File.basename(@path), @path)
          end
        end

        module InstanceMethods
          attr_reader :exec

          def merge_exec(path)
            @exec ||= nil 

            unless @exec.nil?
              IronWorkerNG::Logger.warn "Ignoring attempt to merge binary exec with path='#{path}'"
              return
            end

            @name ||= File.basename(path).gsub(/\..*$/, '').capitalize.gsub(/_./) { |x| x[1].upcase }

            @exec = IronWorkerNG::Feature::Binary::MergeExec::Feature.new(path)

            IronWorkerNG::Logger.info "Merging binary exec with path='#{path}'"

            @features << @exec
          end

          alias :merge_worker :merge_exec

          def self.included(base)
            IronWorkerNG::Code::Base.register_feature(:name => 'merge_exec', :for_klass => base, :args => 'PATH')
          end
        end
      end
    end
  end
end
