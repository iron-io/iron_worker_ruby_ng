require 'fileutils'

require 'iron_worker_ng/code/container/base'
require 'iron_worker_ng/code/container/zip'
require 'iron_worker_ng/code/container/dir'
require 'iron_worker_ng/feature/base'
require 'iron_worker_ng/feature/common/merge_exec'
require 'iron_worker_ng/feature/common/merge_file'
require 'iron_worker_ng/feature/common/merge_dir'
require 'iron_worker_ng/feature/common/merge_deb'

module IronWorkerNG
  module Code
    class Base
      attr_accessor :features
      attr_accessor :fixators

      attr_accessor :base_dir
      attr_accessor :dest_dir

      attr_accessor :use_local_iron_worker_ng

      undef exec
      undef gem

      include IronWorkerNG::Feature::Common::MergeFile::InstanceMethods
      include IronWorkerNG::Feature::Common::MergeDir::InstanceMethods
      include IronWorkerNG::Feature::Common::MergeDeb::InstanceMethods

      def initialize(*args, &block)
        @features = []
        @fixators = []

        @base_dir = ''
        @dest_dir = ''

        @full_remote_build = false

        @runtime = nil

        @name = nil
        @exec = nil

        @use_local_iron_worker_ng = false

        worker_files = []

        if args.length == 1 && args[0].is_a?(String)
          if args[0].end_with?('.worker')
            @name = args[0].gsub(/\.worker$/, '')
          else
            @name = args[0]
          end
        elsif args.length == 1 && args[0].is_a?(Hash)
          @name = args[0][:name] || args[0]['name']

          worker_file = args[0][:workerfile] || args[0]['workerfile']
          worker_files << worker_file unless worker_file.nil?

          exec = args[0][:exec] || args[0]['exec'] || args[0][:worker] || args[0]['worker']
          unless exec.nil?
            merge_exec(exec)
          end
        end

        if @name.nil? and (not @exec.nil?)
          @name = guess_name_for_path(@exec.path)
        end

        unless @name.nil?
          worker_files << @name + '.worker'
        end

        worker_files.each do |worker_file|
          IronWorkerNG::Fetcher.fetch(worker_file) do |content|
            unless content.nil?
              IronCore::Logger.info 'IronWorkerNG', "Found workerfile with path='#{worker_file}'"

              if IronWorkerNG::Fetcher.remote?(worker_file)
                @full_remote_build = true
              end

              @base_dir = File.dirname(worker_file) == '.' ? '' : File.dirname(worker_file) + '/'

              eval(content)

              break
            end
          end
        end

        unless block.nil?
          instance_eval(&block)
        end

        if @name.nil? and (not @exec.nil?)
          @name = guess_name_for_path(@exec.path)
        end

        unless @name.nil?
          @name = File.basename(@name)
        end
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
        File.basename(path).gsub(/#{File.extname(path)}$/, '')
      end

      def name(name = nil)
        @name = name if name

        @name
      end

      def name=(name)
        @name = name
      end

      def remote_build_command(remote_build_command = nil)
        @remote_build_command = remote_build_command unless remote_build_command.nil?

        @remote_build_command
      end

      def remote_build_command=(remote_build_command)
        @remote_build_command = remote_build_command
      end

      alias :build :remote_build_command
      alias :build= :remote_build_command=

      def full_remote_build(full_remote_build = nil)
        @full_remote_build = full_remote_build unless full_remote_build.nil?

        @full_remote_build
      end

      def full_remote_build=(full_remote_build)
        @full_remote_build = full_remote_build
      end

      def remote
        @full_remote_build = true
      end

      def runtime(runtime = nil)
        return @runtime unless runtime

        unless @runtime.nil?
          IronCore::Logger.error 'IronWorkerNG', "Runtime is already set to '#{@runtime}'", IronCore::Error
        end

        runtime_module = nil
        runtime = runtime.to_s

        begin
          runtime_module = IronWorkerNG::Code::Runtime.const_get(runtime.capitalize)
        rescue
          begin
            runtime_module = IronWorkerNG::Code::Runtime.const_get(runtime.upcase)
          rescue
          end
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

      def runtime_bundle(container, local = false)
      end

      def runtime_run_code(local = false)
        ''
      end

      def bundle(container, local = false)
        @features.each do |feature|
          feature.bundle(container)
        end

        if local || ((not remote_build_command) && (not full_remote_build))
          container.get_output_stream(@dest_dir + '__runner__.sh') do |runner|
            runner.write <<RUNNER
#!/bin/sh
# #{IronWorkerNG.full_version}

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

LD_LIBRARY_PATH=.:./lib:./__debs__/usr/lib:./__debs__/usr/lib/x86_64-linux-gnu:./__debs__/lib:./__debs__/lib/x86_64-linux-gnu
export LD_LIBRARY_PATH

PATH=.:./bin:./__debs__/usr/bin:./__debs__/bin:$PATH
export PATH

#{runtime_run_code(local)}
RUNNER
          end

          runtime_bundle(container, local)
        end
      end

      def create_container(local = false)
        if @exec.nil?
          IronCore::Logger.error 'IronWorkerNG', 'No exec specified, check if worker file name is correct and/or exec command is present', IronCore::Error
        end

        if @name.nil?
          @name = guess_name_for_path(@exec.path)
        end

        fixate

        container = local ? IronWorkerNG::Code::Container::Dir.new : IronWorkerNG::Code::Container::Zip.new

        IronCore::Logger.debug 'IronWorkerNG', "Creating #{local ? 'local ' : ''}code container '#{container.name}'"

        if local
          bundle(container, local)
        else
          if @remote_build_command || @full_remote_build
            @dest_dir = '__build__/'
          end

          bundle(container, local)

          if @remote_build_command || @full_remote_build
            IronCore::Logger.info 'IronWorkerNG', 'Remote building worker'

            builder = IronWorkerNG::Code::Builder.new
            builder.builder_remote_build_command = @remote_build_command

            builder.use_local_iron_worker_ng = @use_local_iron_worker_ng

            if @use_local_iron_worker_ng
              builder.gem('iron_worker_ng')
              builder.fixate
            end

            builder.bundle(container, local)

            container.get_output_stream(@name + '.worker') do |wf|
              wf.write(build_workerfile)
            end
          end

          if @remote_build_command || @full_remote_build
            @dest_dir = ''
          end
        end

        container.close

        container.name
      end

      def run(params = {})
        container_name = create_container(true)

        payload = File.open("#{container_name}/__payload__", 'wb')
        payload.write(params.is_a?(String) ? params : params.to_json)
        payload.close

        if @remote_build_command
          system("cd #{container_name} && #{@remote_build_command}")
        end

        system("sh #{container_name}/__runner__.sh -d #{container_name} -payload #{container_name}/__payload__ -id 0")

        FileUtils.rm_rf(container_name)
      end

      def install(standalone = false)
      end

      def build_workerfile
        commands = []

        commands << "runtime '#{runtime}'"
        commands << "name '#{name}'"

        commands += @features.map { |f| f.build_command }

        commands.compact.uniq.join("\n")
      end

      def to_s
        "runtime='#{@runtime}', name='#{@name}', exec='#{@exec.nil? ? '' : @exec.path}'"
      end
    end
  end
end
