require_relative '../feature/ruby/merge_gem'

module IronWorkerNG
  module Code
    class Builder < IronWorkerNG::Code::Ruby
      def bundle(zip)
        @exec = IronWorkerNG::Feature::Ruby::MergeExec::Feature.new(self, '__builder__.rb', nil)

        super(zip)

        zip.get_output_stream(@dest_dir + '__builder__.sh') do |builder|
          builder.write <<BUILDER_SH
# iron_worker_ng-#{IronWorkerNG.full_version}
#{remote_build_command}
BUILDER_SH
        end

        zip.get_output_stream(@dest_dir + '__builder__.rb') do |builder|
          builder.write <<BUILDER_RUBY
# iron_worker_ng-#{IronWorkerNG.full_version}

require 'iron_worker_ng'
require 'json'

puts `cd __build__ && sh ../__builder__.sh && cd ..`

Dir.chdir('__build__')

code = IronWorkerNG::Code::Base.new
code.name params[:code_name]
code.dir '.'

client = IronWorkerNG::Client.new(:token => params[:iron_token], :project_id => params[:iron_project_id])

client.codes.create(code, JSON.parse(params[:codes_create_options]))
BUILDER_RUBY
        end
      end
    end
  end
end
