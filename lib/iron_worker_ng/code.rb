require 'tmpdir'
require 'zip/zip'

require_relative 'feature/base'
require_relative 'feature/common/merge_file'
require_relative 'feature/common/merge_dir'

module IronWorkerNG
  class Code
    attr_reader :features
    attr_accessor :base_dir
    attr_accessor :dest_dir

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
      return if feature[:for_klass].to_s == 'IronWorkerNG::Builder'

      @@registered_features << feature
    end

    def guess_name_for_path(path)
      File.basename(path).
        gsub(/\..*$/, '').
        capitalize.
        gsub(/_./) { |x| x[1].upcase }
    end

    include IronWorkerNG::Feature::Common::MergeFile::InstanceMethods
    include IronWorkerNG::Feature::Common::MergeDir::InstanceMethods

    def initialize(*args, &block)
      @features = []
      @base_dir = ''
      @dest_dir = ''

      @runtime = nil

      @name = nil
      @exec = nil

      wfiles = []

      if args.length == 1 && args[0].class == String
        merge_exec(args[0])
      elsif args.length == 1 && args[0].class == Hash
        opt = args[0]

        @name = opt[:name] || opt['name']

        if rt = opt[:runtime] || opt['runtime']
          runtime(rt)
        end

        if wf = opt[:workerfile] || opt['workerfile']
          wfiles << wf
        end

        if exec = (opt[:exec]   || opt['exec'] ||
                   opt[:worker] || opt['worker'])
          merge_exec(exec)
        end
      end

      if @name.nil? and @exec
        @name = guess_name_for_path(@exec.path)
      end

      unless name.nil?
        wfiles << name + '.worker'
        wfiles << name + '.workerfile'
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

      if @name.nil? and @exec
        @name = guess_name_for_path(@exec.path)
      end
    end

    def merge_exec(*args,&block)
      runtime 'ruby'
      self.merge_exec(*args,&block)
    end
    alias :exec :merge_exec
    alias :merge_worker :merge_exec
    alias :worker :merge_worker

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

      IronCore::Logger.error 'IronWorkerNG', "Runtime is already set to #{@runtime}", IronCore::Error if @runtime

      rt = Code.registered_types.find { |r| r[:name] == runtime }
      self.extend(rt[:klass])

      @runtime = runtime
    end

    def fixate
      IronWorkerNG::Code.registered_features.each do |rf|
        if respond_to?(rf[:name] + '_fixate')
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

#{run_code}
RUNNER
      end
    end

    def create_zip
      unless @exec
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

      zip_name
    end

    def run_code
      ''
    end
  end
end

require_relative 'code/binary'
require_relative 'code/builder'
require_relative 'code/java'
require_relative 'code/node'
require_relative 'code/ruby'
