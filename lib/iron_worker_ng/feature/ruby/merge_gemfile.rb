require 'bundler'

module IronWorkerNG
  module Feature
    module Ruby
      module MergeGemfile
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path
          attr_reader :groups

          def initialize(code, path, groups)
            super(code)

            @path = path
            @groups = groups
          end

          def hash_string
            Digest::MD5.hexdigest(@path + File.mtime(rebase(@path)).to_i.to_s + (File.exists?(rebase(@path) + '.lock') ? File.mtime(rebase(@path) + '.lock').to_i.to_s : '') + @groups.join)
          end
        end

        module InstanceMethods
          def merge_gemfile(path, *groups)
            groups = groups.map { |g| g.to_sym }
            groups << :default if groups.length == 0

            IronCore::Logger.info 'IronWorkerNG', "Adding ruby gems dependencies from #{groups.join(', ')} group#{groups.length > 1 ? 's' : ''} of #{path}"

            specs = Bundler::Definition.build(path, path + '.lock', nil).specs_for(groups)

            specs.each do |spec|
              merge_gem(spec.name, spec.version.to_s)
            end

            @features << IronWorkerNG::Feature::Ruby::MergeGemfile::Feature.new(self, path, groups)
          end

          alias :gemfile :merge_gemfile

          def self.included(base)
            IronWorkerNG::Code::Base.register_feature(:name => 'merge_gemfile', :for_klass => base, :args => 'PATH[,GROUP...]')
          end
        end
      end
    end
  end
end
