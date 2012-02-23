require_relative 'api_client'

module IronWorkerNG
  class ClientProxyCaller
    def initialize(client, prefix)
      @client = client
      @prefix = prefix
    end

    def method_missing(name, *args, &block)
      full_name = @prefix.to_s + '_' + name.to_s
      if @client.respond_to?(full_name)
        @client.send(full_name, *args, &block)
      else
        super
      end
    end
  end

  class Client
    attr_reader :api

    def initialize(token, project_id, params = {})
      @api = IronWorkerNG::APIClient.new(token, project_id, params)
    end

    def method_missing(name, *args, &block)
      if args.length == 0
        IronWorkerNG::ClientProxyCaller.new(self, name)
      else
        super
      end
    end

    def codes_create(code)
      zip_file = code.create_zip
      @api.codes_create(code.name, zip_file, code.runtime, code.runner)
      File.unlink(zip_file)

      true
    end

    def tasks_create(code_name, params = {}, options = {})
      res = @api.tasks_create(code_name, {:project_id => @api.project_id, :token => @api.token, :params => params}.to_json, options)

      res['tasks'][0]['id']
    end

    def schedules_create(code_name, params = {}, options = {})
      res = @api.schedules_create(code_name, {:project_id => @api.project_id, :token => @api.token, :params => params}.to_json, options)

      res['schedules'][0]['id']
    end
  end
end
