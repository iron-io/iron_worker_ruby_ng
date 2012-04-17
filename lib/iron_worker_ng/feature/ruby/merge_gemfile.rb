require 'bundler'

module IronWorkerNG
  module Feature
    module Ruby
      module MergeGemfile
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path
          attr_reader :groups

          def initialize(path, groups)
            @path = File.expand_path(path)
            @groups = groups
          end

          def hash_string
            Digest::MD5.hexdigest(@path + File.mtime(@path).to_i.to_s + (File.exists?(@path + '.lock') ? File.mtime(@path + '.lock').to_i.to_s : '') + @groups.join)
          end
        end

        module InstanceMethods
          def merge_gemfile(path, *groups)
            groups = groups.map { |g| g.to_sym }
            groups << :default if groups.length == 0

            IronWorkerNG::Logger.info "Adding ruby gems dependencies from #{groups.join(', ')} group#{groups.size > 1 ? 's' : ''} of #{path}"

            specs = Bundler::Definition.build(path, path + '.lock', nil).specs_for(groups)

            specs.each do |spec|
              merge_gem(spec.name, spec.version.to_s)
            end

            @features << IronWorkerNG::Feature::Ruby::MergeGemfile::Feature.new(path, groups)
          end

          def self.included(base)
            IronWorkerNG::Code::Base.register_feature(:name => 'merge_gemfile', :for_klass => base, :args => 'PATH[,GROUP...]')
          end
        end
      end
    end
  end
end
