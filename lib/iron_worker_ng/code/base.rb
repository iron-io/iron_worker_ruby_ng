require 'tmpdir'
require 'zip/zip'

require_relative '../feature/base'
require_relative '../feature/common/merge_file'
require_relative '../feature/common/merge_dir'

module IronWorkerNG
  module Code
    class Base
      attr_accessor :features
      attr_accessor :fixators

      attr_accessor :base_dir
      attr_accessor :dest_dir

      undef exec

      include IronWorkerNG::Feature::Common::MergeFile::InstanceMethods
      include IronWorkerNG::Feature::Common::MergeDir::InstanceMethods

      def initialize(*args, &block)
        @features = []
        @fixators = []

        @base_dir = ''
        @dest_dir = ''

        @runtime = nil

        @name = nil
        @exec = nil

        wfiles = []

        if args.length == 1 && args[0].is_a?(String)
          if args[0].end_with?('.worker') || args[0].end_with?('.workerfile')
            wfiles << args[0]
          else
            @name = args[0]
          end
        elsif args.length == 1 && args[0].is_a?(Hash)
          @name = args[0][:name] || args[0]['name']

          wfile = args[0][:workerfile] || args[0]['workerfile']
          wfiles << wfile unless wfile.nil?

          exec = args[0][:exec] || args[0]['exec'] || args[0][:worker] || opt['worker']
          unless exec.nil?
            merge_exec(exec)
          end
        end

        if @name.nil? and (not @exec.nil?)
          @name = guess_name_for_path(@exec.path)
        end

        unless @name.nil?
          wfiles << @name + '.worker'
          wfiles << @name + '.workerfile'
        end

        wfiles << 'Workerfile'

        wfiles.each do |wfile|
          src, clean = IronWorkerNG::Fetcher.fetch(wfile)

          unless src.nil?
            IronCore::Logger.info 'IronWorkerNG', "Using workerfile #{wfile}"

            eval(src)

            @base_dir = File.dirname(wfile) == '.' ? '' : File.dirname(wfile) + '/'

            break
          end
        end

        unless block.nil?
          instance_eval(&block)
        end

        if @name.nil? and (not @exec.nil?)
          @name = guess_name_for_path(@exec.path)
        end

        @name = File.basename(@name)
      end

      def method_missing(name, *args, &block)
        if @runtime.nil?
          runtime(:ruby)
          send(name, *args, &block)
        else
          super(name, *args, &block)
        end
      end

      def guess_name_for_path(path)
        File.basename(path).gsub(/File.extname(path)$/, '').capitalize.gsub(/_./) { |x| x[1].upcase }
      end

      def name(name = nil)
        @name = name if name

        @name
      end

      def name=(name)
        @name = name
      end

      def remote_build_command(remote_build_command = nil)
        @remote_build_command = remote_build_command if remote_build_command

        @remote_build_command
      end

      def remote_build_command=(remote_build_command)
        @remote_build_command = remote_build_command
      end

      def runtime(runtime = nil)
        return @runtime unless runtime

        unless @runtime.nil?
          IronCore::Logger.error 'IronWorkerNG', "Runtime is already set to #{@runtime}", IronCore::Error
        end

        runtime_module = nil

        begin
          runtime_module = IronWorkerNG::Code::Runtime.const_get(runtime.to_s.capitalize)
        rescue
        end

        if runtime_module.nil?
          IronCore::Logger.error 'IronWorkerNG', "Can't find runtime '#{runtime}'"
        end

        self.extend(runtime_module)

        @runtime = runtime
      end

      def runtime=(runtime)
        runtime(runtime)
      end

      def fixate
        @fixators.each do |f|
          send(f)
        end
      end

      def hash_string
        fixate

        Digest::MD5.hexdigest(@features.map { |f| f.hash_string }.join)
      end

      def runtime_bundle(zip)
      end

      def runtime_run_code
        ''
      end

      def bundle(zip)
        @features.each do |feature|
          feature.bundle(zip)
        end

        zip.get_output_stream(@dest_dir + '__runner__.sh') do |runner|
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

#{runtime_run_code}
RUNNER
        end

        runtime_bundle(zip)
      end

      def create_zip
        if @exec.nil?
          IronCore::Logger.error 'IronWorkerNG', 'No exec specified', IronCore::Error
        end

        if @name.nil?
          @name = guess_name_for_path(@exec.path)
        end

        fixate

        zip_name = Dir.tmpdir + '/' + Dir::Tmpname.make_tmpname("iron-worker-ng-", "code.zip")

        IronCore::Logger.debug 'IronWorkerNG', "Creating code zip '#{zip_name}'"

        if @remote_build_command
          @dest_dir = '__build__/'
        end

        Zip::ZipFile.open(zip_name, Zip::ZipFile::CREATE) do |zip|
          bundle(zip)

          if @remote_build_command
            IronCore::Logger.info 'IronWorkerNG', 'Creating builder'
            builder = IronWorkerNG::Builder.new self
            builder.fixate
            builder.bundle(zip)
          end
        end

        if @remote_build_command
          @dest_dir = ''
        end

        zip_name
      end

      def run_code
        ''
      end
    end
  end
end
