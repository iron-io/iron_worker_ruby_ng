require 'zip/zip'

module IronWorkerNG
  module Features
    module Java
      class JarMerger < IronWorkerNG::Features::Feature
        attr_reader :path

        def initialize(path)
          @path = File.expand_path(path)
        end

        def hash_string
          Digest::MD5.hexdigest(@path + File.mtime(@path).to_i.to_s)
        end

        def bundle(zip)
          zip.add(File.basename(@path), @path)
        end

        def code_for_classpath
          File.basename(@path)
        end
      end

      module InstanceMethods
        def merge_jar(path)
          @features ||= []

          @features << IronWorkerNG::Features::Java::JarMerger.new(path)
        end
      end
    end
  end
end
