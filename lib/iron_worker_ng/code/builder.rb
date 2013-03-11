require 'iron_worker_ng/feature/ruby/merge_gem'

module IronWorkerNG
  module Code
    class Builder < IronWorkerNG::Code::Base
      attr_accessor :builder_remote_build_command

      def initialize(*args, &block)
        @features = []
        @fixators = []

        @base_dir = ''
        @dest_dir = ''

        @remote_build_command = nil
        @full_remote_build = false

        @use_local_iron_worker_ng = false

        runtime(:ruby)
      end

      def bundle(container, local = false)
        @exec = IronWorkerNG::Feature::Common::MergeExec::Feature.new(self, '__builder__.rb', {})

        super(container, local)

        if builder_remote_build_command
          container.get_output_stream(@dest_dir + '__builder__.sh') do |builder|
            builder.write <<BUILDER_SH
# #{IronWorkerNG.full_version}
#{builder_remote_build_command}
BUILDER_SH
          end
        end

        install_iron_worker_ng = ''

        if not @use_local_iron_worker_ng
          install_iron_worker_ng = "system('gem install iron_worker_ng -v #{IronWorkerNG::VERSION}')"
        end

        container.get_output_stream(@dest_dir + '__builder__.rb') do |builder|
          builder.write <<BUILDER_RUBY
# #{IronWorkerNG.full_version}

require 'json'

File.open('.gemrc', 'w') do |gemrc|
  gemrc.puts('gem: --no-ri --no-rdoc')
end

#{install_iron_worker_ng}

require 'iron_worker_ng'

IronWorkerNG::Feature::Ruby::MergeGem.merge_binary = true

code = IronWorkerNG::Code::Base.new(params[:code_name])

if not File.exists?('bundler.magic')
  deps = code.features.reject { |f| f.class != IronWorkerNG::Feature::Ruby::MergeGemDependency::Feature }

  deps.each do |dep|
    if dep.name == 'bundler' and dep.version != '>= 0'
      system('touch bundler.magic')
      system('gem uninstall bundler')
      system("gem install bundler -v '\#{dep.version}'")
      success = system("ruby __runner__.rb \#{ARGV.join(' ')}")
      exit(success ? 0 : 1)
    end
  end
end

if File.exists?('__builder__.sh')
  pre_build_list = Dir.glob('__build__/**/**')

  exit 1 unless system('cd __build__ && sh ../__builder__.sh && cd ..')

  post_build_list = Dir.glob('__build__/**/**')

  (post_build_list.sort - pre_build_list.sort).each do |new_file|
    code.file(new_file, File.dirname(new_file[10 .. -1])) if File.file?(new_file)
  end
end

code.install(true)

require 'bundler/setup'

client = IronWorkerNG::Client.new(JSON.parse(params[:client_options]))

res = client.codes.create(code, JSON.parse(params[:codes_create_options]))

client.tasks.set_progress(iron_task_id, :msg => res.marshal_dump.to_json)
BUILDER_RUBY
        end
      end
    end
  end
end
