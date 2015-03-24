module IronWorkerNG
  module Feature
    module Python
      module MergeRequirements
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path

          def initialize(code, path)
            super(code)

            @path = path
          end
        end

        module InstanceMethods
          def merge_requirements(path)
            feature = IronWorkerNG::Feature::Python::MergeRequirements::Feature.new(self, path)
            IronWorkerNG::Fetcher.fetch_to_file(feature.rebase(path)) do |requirements|
              specs = []
              File.readlines(requirements).map { |line| specs << line.split('==')}
              specs.each {|spec| merge_pip(spec[0], spec[1])}
            end
            @features << feature
          end

          alias :requirements :merge_requirements
        end
      end
    end
  end
end

