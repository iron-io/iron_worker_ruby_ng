require 'iron_worker_ng/api_client'
require 'iron_worker_ng/code'

module IronWorkerNG
  class Client
    def initialize(project_id, token)
      @api = IronWorkerNG::APIClient.new(project_id, token)
    end

    def upload(&block)
      code = IronWorkerNG::Code.new
      
      yield code

      zip_file = code.create_zip
      @api.codes_create(code.main_worker.name, zip_file)
      File.unlink(zip_file)
    end

    def queue(name)
      @api.tasks_create(name)
    end
  end
end
