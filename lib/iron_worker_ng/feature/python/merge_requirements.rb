module IronWorkerNG
  module Feature
    module Python
      module MergeRequirements
        module InstanceMethods
          def merge_requirements(path)
            feature = IronWorkerNG::Feature::Base.new(self)
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

