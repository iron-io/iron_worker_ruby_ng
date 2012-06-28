require_relative '../feature/ruby/merge_gem'

module IronWorkerNG
  class Builder < Code

    def initialize(src)
      @features = []
      @base_dir = ''
      @dest_dir = ''

      @name = nil
      @exec = nil

      runtime 'ruby'

      gem 'iron_worker_ng'

      file(File.open(Dir.mktmpdir + '/__builder__.sh') do |f|
             f <<BUILDER_SH
# iron_worker_ng-#{IronWorkerNG.full_version}
#{src.remote_build_command}
BUILDER_SH
           end.path)

      exec(File.open(Dir.mktmpdir + '/__builder__.rb', 'w') do |f|
             f <<BUILDER_RUBY
# iron_worker_ng-#{IronWorkerNG.full_version}

require 'iron_worker_ng'
require 'json'

exit 1 unless system('cd __build__ && sh ../__builder__.sh && cd ..')

Dir.chdir('__build__')

code = IronWorkerNG::Code.new do
  runtime '#{src.runtime}'
  name '#{src.name}'
  exec '#{src.exec}'
  dir '.'
end

client = IronWorkerNG::Client.new(:token => params[:iron_token], :project_id => params[:iron_project_id])

res = client.codes.create(code, JSON.parse(params[:codes_create_options]))

client.tasks.set_progress(iron_task_id, :msg => res.marshal_dump.to_json)
BUILDER_RUBY
           end.path)
    end
  end
end
