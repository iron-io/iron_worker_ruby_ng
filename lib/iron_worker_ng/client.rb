require_relative 'api_client'
require_relative 'package'

module IronWorkerNG
  class Client
    def initialize(project_id, token)
      @api = IronWorkerNG::APIClient.new(project_id, token)
    end

    def upload(package)
      zip_file = package.create_zip
      @api.codes_create(package.main_worker.name, zip_file)
      File.unlink(zip_file)
    end

    def queue(name)
      @api.tasks_create(name)
    end
  end
end
