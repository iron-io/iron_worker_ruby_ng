module IronWorkerNG
  module Feature
    module Common
      module MergeFile
        class Feature < IronWorkerNG::Feature::Base
          attr_reader :path
          attr_reader :dest

          def initialize(path, dest)
            @path = File.expand_path(path)
            @dest = dest
          end

          def hash_string
            Digest::MD5.hexdigest(@path + @dest + File.mtime(@path).to_i.to_s)
          end

          def bundle(zip)
            zip.add(@dest + File.basename(@path), @path)
          end
        end

        module InstanceMethods
          def merge_file(path, dest = '')
            @features << IronWorkerNG::Feature::Common::MergeFile::Feature.new(path, dest)
          end

          def self.included(base)
            IronWorkerNG::Code::Base.register_feature(:name => 'merge_file', :for_klass => base, :args => 'PATH[,DEST]')
          end
        end
      end
    end
  end
end
