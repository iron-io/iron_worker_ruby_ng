require_relative 'api_client'
require_relative 'package'
require_relative 'ruby_package'

module IronWorkerNG
  class Client
    def initialize(project_id, token)
      @api = IronWorkerNG::APIClient.new(project_id, token)
    end

    def upload(package)
      zip_file = package.create_zip
      @api.codes_create(package.name, zip_file, package.runtime, package.runner)
      File.unlink(zip_file)
    end

    def queue(package_name, params)
      @api.tasks_create(package_name, {:project_id => @api.project_id, :token => @api.token, :params => params})
    end
  end
end
