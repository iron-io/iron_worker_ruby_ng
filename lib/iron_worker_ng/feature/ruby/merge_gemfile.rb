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
        end

        module InstanceMethods
          def merge_gemfile(path, *groups)
            groups = groups.map { |g| g.to_sym }
            groups << :default if groups.length == 0

            IronCore::Logger.info 'IronWorkerNG', "Adding ruby gems dependencies from #{groups.join(', ')} group#{groups.length > 1 ? 's' : ''} of #{path}"

            feature = IronWorkerNG::Feature::Ruby::MergeGemfile::Feature.new(self, path, groups)

            IronWorkerNG::Fetcher.fetch_to_file(feature.rebase(path)) do |gemfile|
              specs = Bundler::Definition.build(gemfile, path + '.lock', nil).specs_for(groups)

              specs.each do |spec|
                merge_gem(spec.name, spec.version.to_s)
              end
            end

            @features << feature
          end

          alias :gemfile :merge_gemfile
        end
      end
    end
  end
end
