require 'pathname'

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
            @dest = Pathname.new(dest).cleanpath.to_s + '/' unless @dest.empty?
          end

          def hash_string
            Digest::MD5.hexdigest(@path + @dest + File.mtime(@path).to_i.to_s)
          end

          def bundle(zip)
            IronWorkerNG::Logger.debug "Bundling file with path='#{@path}' and dest='#{@dest}'"

            zip.add(@dest + File.basename(@path), @path)
          end
        end

        module InstanceMethods
          def merge_file(path, dest = '')
            IronWorkerNG::Logger.info "Merging file with path='#{path}' and dest='#{dest}'"

            @features << IronWorkerNG::Feature::Common::MergeFile::Feature.new(path, dest)
          end

          alias :file :merge_file

          def self.included(base)
            IronWorkerNG::Code::Base.register_feature(:name => 'merge_file', :for_klass => base, :args => 'PATH[,DEST]')
          end
        end
      end
    end
  end
end
