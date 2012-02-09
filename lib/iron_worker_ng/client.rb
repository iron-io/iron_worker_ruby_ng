require 'rest_client'
require 'json'

module IronWorkerNG
  class Client
    def initialize(project_id, token)
      @project_id = project_id
      @token = token

      @url = 'https://worker-aws-us-east-1.iron.io/2/'
    end

    def common_request_hash
      {
        :accept => 'json',
        :content_type => 'json',
        :authorization => "OAuth #{@token}",
        :user_agent => 'IronWorker Ruby Client NG'
      }
    end

    def get(method, params = {})
      request_hash = common_request_hash
      request_hash[:params] = params

      RestClient.get(@url + method, request_hash) 
    end

    def post(method, params = {})
      request_hash = common_request_hash
      request_hash[:body] = params

      RestClient.post(@url + method, request_hash) 
    end

    def codes_list
      response = get("/projects/#{@project_id}/codes")

      return nil if response.code != 200
      JSON.parse(response.to_s)['codes']
    end

    def codes_create(name, file)
      response = post("/projects/#{@project_id}/codes", {:name => name, :file => File.new(file, 'rb'), :file_name => 'runner.rb', :runtime => 'ruby'})
    end
  end
end
