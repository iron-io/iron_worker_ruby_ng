require 'tmpdir'
require 'zip/zip'

require_relative '../feature/base'
require_relative '../feature/common/merge_file'
require_relative '../feature/common/merge_dir'

module IronWorkerNG
  module Code
    class Base
      attr_reader :features

      @@registered_types = []
    
      def self.registered_types
        @@registered_types
      end
    
      def self.register_type(type)
        @@registered_types << type
      end

      @@registered_features = []
    
      def self.registered_features
        @@registered_features
      end
    
      def self.register_feature(feature)
        @@registered_features << feature
      end

      def self.guess_name_for_path(path)
        File.basename(path).gsub(/\..*$/, '').capitalize.gsub(/_./) { |x| x[1].upcase }
      end

      include IronWorkerNG::Code::Initializer::InstanceMethods

      include IronWorkerNG::Feature::Common::MergeFile::InstanceMethods
      include IronWorkerNG::Feature::Common::MergeDir::InstanceMethods

      def initialize(*args, &block)
        @features = []

        initialize_code(*args, &block)
      end

      def name(code_name = nil)
        @name = code_name if code_name

        if @name.nil? and @exec
          @name = IronWorkerNG::Code::Base.guess_name_for_path(@exec.path)
          IronCore::Logger.info 'IronWorkerNG', "defaulting name to #{@name}"
        end

        @name
      end

      def name=(name)
        @name = name
      end

      def runtime(*args)
      end

      def runtime=(runtime)
      end

      def fixate
        IronWorkerNG::Code::Base.registered_features.each do |rf|
          if rf[:for_klass] == self.class && respond_to?(rf[:name] + '_fixate')
            send(rf[:name] + '_fixate')
          end
        end
      end

      def hash_string
        fixate

        Digest::MD5.hexdigest(@features.map { |f| f.hash_string }.join)
      end

      def bundle(zip)
        @features.each do |feature|
          feature.bundle(zip)
        end
      end

      def create_zip
        unless @exec
          IronCore::Logger.error 'IronWorkerNG', 'No exec specified'
          raise IronCore::IronError.new('No exec specified')
        end

        fixate

        zip_name = Dir.tmpdir + '/' + Dir::Tmpname.make_tmpname("iron-worker-ng-", "code.zip")

        IronCore::Logger.debug 'IronWorkerNG', "Creating code zip '#{zip_name}'"

        Zip::ZipFile.open(zip_name, Zip::ZipFile::CREATE) do |zip|
          bundle(zip)

          zip.get_output_stream('__runner__.sh') do |runner|
            runner.write <<RUNNER
#!/bin/sh
# iron_worker_ng-#{IronWorkerNG.full_version}

root() {
  while [ $# -gt 1 ]; do
    if [ "$1" = "-d" ]; then
      printf "%s" "$2"
      break
    fi

    shift
  done
}

cd "$(root "$@")"

#{run_code}
RUNNER
          end
        end

        zip_name
      end

      def run_code
        ''
      end
    end
  end
end
