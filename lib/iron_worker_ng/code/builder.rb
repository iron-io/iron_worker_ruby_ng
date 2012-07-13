require_relative '../feature/ruby/merge_gem'

module IronWorkerNG
  module Code
    class Builder < IronWorkerNG::Code::Base
      def initialize(*args, &block)
        @features = []
        @fixators = []

        @base_dir = ''
        @dest_dir = ''

        runtime(:ruby)
      end

      def bundle(container)
        @exec = IronWorkerNG::Feature::Ruby::MergeExec::Feature.new(self, '__builder__.rb', nil)

        super(container)

        container.get_output_stream(@dest_dir + '__builder__.sh') do |builder|
          builder.write <<BUILDER_SH
# #{IronWorkerNG.full_version}
#{remote_build_command}
BUILDER_SH
        end

        container.get_output_stream(@dest_dir + '__builder__.rb') do |builder|
          builder.write <<BUILDER_RUBY
# #{IronWorkerNG.full_version}

require 'iron_worker_ng'
require 'json'

exit 1 unless system('cd __build__ && sh ../__builder__.sh && cd ..')

Dir.chdir('__build__')

code = IronWorkerNG::Code::Base.new
code.inside_builder = true

code.name params[:code_name]
code.dir '.'

client = IronWorkerNG::Client.new(JSON.parse(params[:client_options]))

res = client.codes.create(code, JSON.parse(params[:codes_create_options]))

client.tasks.set_progress(iron_task_id, :msg => res.marshal_dump.to_json)
BUILDER_RUBY
        end
      end
    end
  end
end
