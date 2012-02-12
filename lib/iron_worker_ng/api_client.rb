require 'rest_client'
require 'json'

module IronWorkerNG
  class APIClient
    attr_reader :project_id
    attr_reader :token

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

      RestClient.post(@url + method, params.to_json, request_hash) 
    end

    def post_file(method, file, params = {})
      request_hash = common_request_hash
      request_hash[:data] = params.to_json
      request_hash[:file] = file

      RestClient.post(@url + method + "?oauth=#{@token}", request_hash) 
    end

    def codes_list
      response = get("projects/#{@project_id}/codes")

      return nil if response.code != 200
      JSON.parse(response.to_s)['codes']
    end

    def codes_create(name, file)
      post_file("projects/#{@project_id}/codes", File.new(file, 'rb'), {:name => name, :file_name => 'runner.rb', :runtime => 'ruby'})
    end

    def tasks_create(code_name, payload = {})
      post("projects/#{@project_id}/tasks", {:tasks => [{:code_name => code_name, :payload => payload.to_json}]})
    end
  end
end
