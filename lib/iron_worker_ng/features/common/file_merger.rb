module IronWorkerNG
  module Features
    module Common
      class FileMerger < IronWorkerNG::Features::Feature
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
          zip.add(@dest + '/' + File.basename(@path), @path)
        end
      end

      module InstanceMethods
        def merge_file(path, dest = '.')
          @features ||= []
          @features << IronWorkerNG::Features::Common::FileMerger.new(path, dest)
        end
      end
    end
  end
end
