require 'rest-client'
require 'rest'
require 'json'
require 'time'

require_relative 'api_client_error'

module IronWorkerNG
  class APIClient
    attr_reader :token
    attr_reader :project_id

    def initialize(token, project_id, params = {})
      @token = token
      @project_id = project_id

      @user_agent = params[:user_agent] || 'iron_worker_ng-' + IronWorkerNG.version

      scheme = params[:scheme] || 'https'
      host = params[:host] || 'worker-aws-us-east-1.iron.io'
      port = params[:port] || 443
      api_version = params[:api_version] || 2

      @url = "#{scheme}://#{host}:#{port}/#{api_version}/"

      @rest = Rest::Client.new
    end

    def common_request_hash
      {
        'Content-Type' => 'application/json',
        'Authorization' => "OAuth #{@token}",
        'User-Agent' => @user_agent
      }
    end

    def get(method, params = {})
      request_hash = {}
      request_hash[:headers] = common_request_hash
      request_hash[:params] = params

      @rest.get(@url + method, request_hash)
    end

    def post(method, params = {})
      request_hash = {}
      request_hash[:headers] = common_request_hash
      request_hash[:body] = params.to_json

      @rest.post(@url + method, request_hash)
    end

    def delete(method, params = {})
      request_hash = {}
      request_hash[:headers] = common_request_hash
      request_hash[:params] = params

      @rest.delete(@url + method, request_hash)
    end

    def post_file(method, file, params = {})
      request_hash = common_request_hash
      request_hash[:data] = params.to_json
      request_hash[:file] = file

      RestClient.post(@url + method + "?oauth=#{@token}", request_hash) 
    end

    def parse_response(response, parse_json = true)
      raise IronWorkerNG::APIClientError.new(response.body) if response.code != 200

      return response.body unless parse_json
      JSON.parse(response.body)
    end

    def codes_list(params = {})
      parse_response(get("projects/#{@project_id}/codes", params))
    end

    def codes_get(id)
      parse_response(get("projects/#{@project_id}/codes/#{id}"))
    end

    def codes_create(name, file, runtime, runner)
      parse_response(post_file("projects/#{@project_id}/codes", File.new(file, 'rb'), {:name => name, :runtime => runtime, :file_name => runner}))
    end

    def codes_delete(id)
      parse_response(delete("projects/#{@project_id}/codes/#{id}"))
    end

    def codes_revisions(id, params = {})
      parse_response(get("projects/#{@project_id}/codes/#{id}/revisions", params))
    end

    def codes_download(id, params = {})
      parse_response(get("projects/#{@project_id}/codes/#{id}/download", params), false)
    end

    def tasks_list(params = {})
      parse_response(get("projects/#{@project_id}/tasks", params))
    end

    def tasks_get(id)
      parse_response(get("projects/#{@project_id}/tasks/#{id}"))
    end

    def tasks_create(code_name, payload, params = {})
      parse_response(post("projects/#{@project_id}/tasks", {:tasks => [{:code_name => code_name, :payload => payload}.merge(params)]}))
    end

    def tasks_cancel(id)
      parse_response(post("projects/#{@project_id}/tasks/#{id}/cancel"))
    end

    def tasks_cancel_all(code_id)
      parse_response(post("projects/#{@project_id}/codes/#{code_id}/cancel_all"))
    end

    def tasks_log(id)
      parse_response(get("projects/#{@project_id}/tasks/#{id}/log"), false)
    end

    def tasks_set_progress(id, params = {})
      parse_response(post("projects/#{@project_id}/tasks/#{id}/progress", params))
    end

    def schedules_list(params = {})
      parse_response(get("projects/#{@project_id}/schedules", params))
    end

    def schedules_get(id)
      parse_response(get("projects/#{@project_id}/schedules/#{id}"))
    end

    def schedules_create(code_name, payload, params = {})
      params[:start_at] = params[:start_at].iso8601 if (not params[:start_at].nil?) && params[:start_at].class == Time
      params[:end_at] = params[:end_at].iso8601 if (not params[:end_at].nil?) && params[:end_at].class == Time

      parse_response(post("projects/#{@project_id}/schedules", {:schedules => [{:code_name => code_name, :payload => payload}.merge(params)]}))
    end

    def schedules_cancel(id)
      parse_response(post("projects/#{@project_id}/schedules/#{id}/cancel"))
    end
  end
end
