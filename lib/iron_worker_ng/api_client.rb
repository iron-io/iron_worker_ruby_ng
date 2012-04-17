require 'rest-client'
require 'rest'
require 'json'
require 'time'

require_relative 'api_client_error'

module IronWorkerNG
  class APIClient
    AWS_US_EAST_HOST = 'worker-aws-us-east-1.iron.io'

    attr_accessor :token
    attr_accessor :project_id
    attr_accessor :scheme
    attr_accessor :host
    attr_accessor :port
    attr_accessor :api_version
    attr_accessor :user_agent

    def initialize(options = {})
      @token = options[:token] || options['token']
      @project_id = options[:project_id] || options['project_id']

      if (not @token) || (not @project_id)
        IronWorkerNG::Logger.error 'Both iron.io token and project_id must be specified' 
        raise 'Both iron.io token and project_id must be specified' 
      end

      @scheme = options[:scheme] || options['scheme'] || 'https'
      @host = options[:host] || options['host'] || IronWorkerNG::APIClient::AWS_US_EAST_HOST
      @port = options[:port] || options['port'] || 443
      @api_version = options[:api_version] || options['api_version'] || 2
      @user_agent = options[:user_agent] || options['user_agent'] || 'iron_worker_ng-' + IronWorkerNG.version

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

      IronWorkerNG::Logger.debug "GET #{@url + method} with params='#{request_hash.to_s}'"

      @rest.get(@url + method, request_hash)
    end

    def post(method, params = {})
      request_hash = {}
      request_hash[:headers] = common_request_hash
      request_hash[:body] = params.to_json

      IronWorkerNG::Logger.debug "POST #{@url + method} with params='#{request_hash.to_s}'" 

      @rest.post(@url + method, request_hash)
    end

    def delete(method, params = {})
      request_hash = {}
      request_hash[:headers] = common_request_hash
      request_hash[:params] = params

      IronWorkerNG::Logger.debug "DELETE #{@url + method} with params='#{request_hash.to_s}'"

      @rest.delete(@url + method, request_hash)
    end

    # FIXME: retries support
    # FIXME: user agent support
    def post_file(method, file, params = {})
      request_hash = {}
      request_hash[:data] = params.to_json
      request_hash[:file] = file

      IronWorkerNG::Logger.debug "POST #{@url + method + "?oauth=" + @token} with params='#{request_hash.to_s}'"

      RestClient.post(@url + method + "?oauth=#{@token}", request_hash) 
    end

    def parse_response(response, parse_json = true)
      IronWorkerNG::Logger.debug "GOT #{response.code} with params='#{response.body}'"

      raise IronWorkerNG::APIClientError.new(response.body) if response.code != 200

      return response.body unless parse_json
      JSON.parse(response.body)
    end

    def codes_list(options = {})
      parse_response(get("projects/#{@project_id}/codes", options))
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

    def codes_revisions(id, options = {})
      parse_response(get("projects/#{@project_id}/codes/#{id}/revisions", options))
    end

    def codes_download(id, options = {})
      parse_response(get("projects/#{@project_id}/codes/#{id}/download", options), false)
    end

    def tasks_list(options = {})
      parse_response(get("projects/#{@project_id}/tasks", options))
    end

    def tasks_get(id)
      parse_response(get("projects/#{@project_id}/tasks/#{id}"))
    end

    def tasks_create(code_name, payload, options = {})
      parse_response(post("projects/#{@project_id}/tasks", {:tasks => [{:code_name => code_name, :payload => payload}.merge(options)]}))
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

    def tasks_set_progress(id, options = {})
      parse_response(post("projects/#{@project_id}/tasks/#{id}/progress", options))
    end

    def schedules_list(options = {})
      parse_response(get("projects/#{@project_id}/schedules", options))
    end

    def schedules_get(id)
      parse_response(get("projects/#{@project_id}/schedules/#{id}"))
    end

    def schedules_create(code_name, payload, options = {})
      options[:start_at] = options[:start_at].iso8601 if (not options[:start_at].nil?) && options[:start_at].class == Time
      options[:end_at] = options[:end_at].iso8601 if (not options[:end_at].nil?) && options[:end_at].class == Time

      parse_response(post("projects/#{@project_id}/schedules", {:schedules => [{:code_name => code_name, :payload => payload}.merge(options)]}))
    end

    def schedules_cancel(id)
      parse_response(post("projects/#{@project_id}/schedules/#{id}/cancel"))
    end
  end
end
