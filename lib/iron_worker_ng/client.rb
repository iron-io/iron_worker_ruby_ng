require_relative 'api_client'

module IronWorkerNG
  class Client
    attr_reader :api

    def initialize(project_id, token, params = {})
      @api = IronWorkerNG::APIClient.new(project_id, token, params)
    end

    def upload(code)
      zip_file = code.create_zip
      @api.codes_create(code.name, zip_file, code.runtime, code.runner)
      File.unlink(zip_file)

      true
    end

    def queue(code_name, params = {}, options = {})
      res = @api.tasks_create(code_name, {:project_id => @api.project_id, :token => @api.token, :params => params}.to_json, options)

      res['tasks'][0]['id']
    end

    def schedule(code_name, params = {}, options = {})
      res = @api.schedules_create(code_name, {:project_id => @api.project_id, :token => @api.token, :params => params}.to_json, options)

      res['schedules'][0]['id']
    end
  end
end
