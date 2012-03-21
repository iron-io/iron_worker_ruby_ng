module IronWorkerNG
  module Feature
    module Common
      module MergeDir
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path
          attr_reader :dest

          def initialize(path, dest)
            @path = File.expand_path(path)
            @dest = dest
          end

          def hash_string
            s = @path + @dest + File.mtime(@path).to_i.to_s

            Dir.glob(@path + '/**/**') do |path|
              s += path + File.mtime(path).to_i.to_s
            end

            Digest::MD5.hexdigest(s)
          end

          def bundle(zip)
            Dir.glob(@path + '/**/**') do |path|
              zip.add(@dest + File.basename(@path) + path[@path.length .. -1], path)
            end
          end
        end

        module InstanceMethods
          def merge_dir(path, dest = '')
            @features << IronWorkerNG::Feature::Common::MergeDir::Feature.new(path, dest)
          end

          def self.included(base)
            IronWorkerNG::Code::Base.register_feature(:name => 'merge_dir', :for_klass => base, :args => 'PATH[,DEST]')
          end
        end
      end
    end
  end
end
