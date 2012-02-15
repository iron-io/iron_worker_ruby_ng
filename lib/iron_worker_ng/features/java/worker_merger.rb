module IronWorkerNG
  module Features
    module Java
      class WorkerMerger < IronWorkerNG::Features::Feature
        attr_reader :path
        attr_reader :klass

        def initialize(path, klass)
          @path = File.expand_path(path)
          @klass = klass
        end

        def hash_string
          Digest::MD5.hexdigest(@path + @klass + File.mtime(@path).to_i.to_s)
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
        attr_reader :worker

        def merge_worker(path, klass)
          @features ||= []
          @worker ||= nil 

          return unless @worker.nil?

          @name ||= klass.split('.')[-1]

          @worker = IronWorkerNG::Features::Java::WorkerMerger.new(path, klass)
          @features << @worker
        end
      end
    end
  end
end
