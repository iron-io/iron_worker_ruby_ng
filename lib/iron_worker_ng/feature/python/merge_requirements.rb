module IronWorkerNG
  module Feature
    module Python
      module MergeRequirements
        module InstanceMethods

          def merge_requirements(path)
            feature = IronWorkerNG::Feature::Base.new(self)
            IronWorkerNG::Fetcher.fetch_to_file(feature.rebase(path)) do |requirements|
              specs = parse_requirements(requirements)
              specs.each {|spec| merge_pip(spec[:name], spec[:version])}
            end
            @features << feature
          end

          alias :requirements :merge_requirements

          private
          def parse_requirements(file)
            specs = []
            File.readlines(file).each do |line|
              line = line.strip
              next if line.to_s.empty? || line.start_with?('#')
              spec = line.split(/(==|>=|<=|<|>)/, 2)
              version = spec[1]? spec[1]+spec[2]: ''
              specs << {name: spec[0], version:version}
            end
            specs
          end
        end
      end
    end
  end
end

