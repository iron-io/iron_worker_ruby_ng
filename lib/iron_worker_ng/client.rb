require_relative 'api_client'

module IronWorkerNG
  class Client
    attr_reader :api

    def initialize(project_id, token, params = {})
      @api = IronWorkerNG::APIClient.new(project_id, token, params)
    end

    def upload(package)
      zip_file = package.create_zip
      @api.codes_create(package.name, zip_file, package.runtime, package.runner)
      File.unlink(zip_file)

      true
    end

    def queue(package_name, params = {}, options = {})
      res = @api.tasks_create(package_name, {:project_id => @api.project_id, :token => @api.token, :params => params}.to_json, options)

      res['tasks'][0]['id']
    end

    def schedule(package_name, params = {}, options = {})
      res = @api.schedules_create(package_name, {:project_id => @api.project_id, :token => @api.token, :params => params}.to_json, options)

      res['schedules'][0]['id']
    end
  end
end
