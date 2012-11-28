require 'iron_worker_ng'
require_relative '../../ruby/examples_helper'

config = ExamplesHelper.load_config

client = IronWorkerNG::Client.new(:token => config['iw']['token'], :project_id => config['iw']['project_id'])

code = IronWorkerNG::Code::Ruby.new
code.merge_worker 'actionmailer_worker.rb'
code.merge_file 'mailer.rb' # merging mailer...
code.merge_dir 'mailer' # ...and templates
code.merge_gem 'actionmailer' # we need actionmailer gem merged as well

client.codes.create(code)
