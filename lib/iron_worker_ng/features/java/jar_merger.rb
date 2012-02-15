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
          Zip::ZipFile.open(@path) do |jar|
            jar.entries.each do |entry|
              next if entry.name.start_with?('META-INF')

              next unless zip.find_entry(entry.name).nil?
              
              if entry.ftype == :directory
                zip.mkdir(entry.name)
              elsif entry.ftype == :file
                zip.get_output_stream(entry.name) { |f| f.write(jar.read(entry.name)) }
              end
            end
          end
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
