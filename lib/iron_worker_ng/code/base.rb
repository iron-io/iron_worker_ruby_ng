require 'tmpdir'
require 'zip/zip'

require_relative '../feature/base'
require_relative '../feature/common/merge_file'
require_relative '../feature/common/merge_dir'

module IronWorkerNG
  module Code
    class Base
      attr_reader :features
      attr_accessor :name

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

      include IronWorkerNG::Feature::Common::MergeFile::InstanceMethods
      include IronWorkerNG::Feature::Common::MergeDir::InstanceMethods

      def initialize(*args, &block)
        @name = nil
        @features = []

        if args.length == 1 && args[0].class == String
          merge_exec(args[0])
        elsif args.length == 1 && args[0].class == Hash
          @name = args[0][:name] || args[0]['name']

          exec = args[0][:exec] || args[0]['exec'] || args[0][:worker] || args[0]['worker']
          merge_exec(exec) unless exec.nil?
        end

        if args.length == 1 && args[0].class == Hash && ((not args[0][:workerfile].nil?) || (not args[0]['workerfile'].nil?))
          eval(File.read(File.expand_path(args[0][:workerfile] || args[0]['workerfile'])))
        end

        unless @exec.nil?
          @name ||= guess_name(@exec.path)
        end

        if (not @name.nil?) && File.exists?(@name + '.worker')
          eval(File.read(@name + '.worker'))
        end

        if (not @name.nil?) && File.exists?(@name + '.workerfile')
          eval(File.read(@name + '.workerfile'))
        end

        if File.exists?('Workerfile')
          eval(File.read('Workerfile'))
        end

        unless block.nil?
          instance_eval(&block)
        end

        unless @exec.nil?
          @name ||= guess_name(@exec.path)
        end
      end

      def guess_name(path)
        File.basename(path).gsub(/\..*$/, '').capitalize.gsub(/_./) { |x| x[1].upcase }
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

        @name ||= guess_name(@exec.path)

        zip_name = Dir.tmpdir + '/' + Dir::Tmpname.make_tmpname("iron-worker-ng-", "code.zip")

        IronCore::Logger.debug 'IronWorkerNG', "Creating code zip '#{zip_name}'"

        Zip::ZipFile.open(zip_name, Zip::ZipFile::CREATE) do |zip|
          bundle(zip)
          create_runner(zip)
        end

        zip_name
      end

      def create_runner(zip)
      end

      def runner
        nil
      end
    end
  end
end
