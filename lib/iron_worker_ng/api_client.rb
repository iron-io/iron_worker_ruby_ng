require 'time'

require 'iron_core'

module IronWorkerNG
  class APIClient < IronCore::Client
    AWS_US_EAST_HOST = 'worker-aws-us-east-1.iron.io'

    def initialize(options = {})
      default_options = {
        :scheme => 'https',
        :host => IronWorkerNG::APIClient::AWS_US_EAST_HOST,
        :port => 443,
        :api_version => 2,
        :user_agent => IronWorkerNG.full_version
      }

      super('iron', 'worker', options, default_options, [:project_id, :token, :api_version])

      IronCore::Logger.error 'IronWorkerNG', "Token is not set", IronCore::Error if @token.nil?

      check_id(@project_id, 'project_id')
    end

    def headers
      super.merge({'Authorization' => "OAuth #{@token}"})
    end

    def base_url
      super + @api_version.to_s + '/'
    end

    def codes_list(options = {})
      parse_response(get("projects/#{@project_id}/codes", options))
    end

    def codes_get(id)
      check_id(id)
      parse_response(get("projects/#{@project_id}/codes/#{id}"))
    end

    def codes_create(name, file, runtime, runner, options)
      parse_response(post_file("projects/#{@project_id}/codes", :file, File.new(file, 'rb'), :data, {:name => name, :runtime => runtime, :file_name => runner}.merge(options)))
    end

    def codes_delete(id)
      check_id(id)
      parse_response(delete("projects/#{@project_id}/codes/#{id}"))
    end

    def codes_revisions(id, options = {})
      check_id(id)
      parse_response(get("projects/#{@project_id}/codes/#{id}/revisions", options))
    end

    def codes_download(id, options = {})
      check_id(id)
      parse_response(get("projects/#{@project_id}/codes/#{id}/download", options), false)
    end

    def tasks_list(options = {})
      parse_response(get("projects/#{@project_id}/tasks", options))
    end

    def tasks_get(id)
      check_id(id)
      parse_response(get("projects/#{@project_id}/tasks/#{id}"))
    end

    def tasks_create(code_name, payload, options = {})
      parse_response(post("projects/#{@project_id}/tasks", {:tasks => [{:code_name => code_name, :payload => payload}.merge(options)]}))
    end

    def tasks_cancel(id)
      check_id(id)
      parse_response(post("projects/#{@project_id}/tasks/#{id}/cancel"))
    end

    def tasks_cancel_all(code_id)
      check_id(id)
      parse_response(post("projects/#{@project_id}/codes/#{code_id}/cancel_all"))
    end

    def tasks_log(id)
      check_id(id)
      parse_response(get("projects/#{@project_id}/tasks/#{id}/log"), false)
    end

    def tasks_set_progress(id, options = {})
      check_id(id)
      parse_response(post("projects/#{@project_id}/tasks/#{id}/progress", options))
    end

    def tasks_retry(id, options = {})
      check_id(id)
      parse_response(post("projects/#{@project_id}/tasks/#{id}/retry", options))
    end

    def schedules_list(options = {})
      parse_response(get("projects/#{@project_id}/schedules", options))
    end

    def schedules_get(id)
      check_id(id)
      parse_response(get("projects/#{@project_id}/schedules/#{id}"))
    end

    def schedules_create(code_name, payload, options = {})
      options[:start_at] = options[:start_at].iso8601 if (not options[:start_at].nil?) && options[:start_at].respond_to?(:iso8601)
      options[:end_at] = options[:end_at].iso8601 if (not options[:end_at].nil?) && options[:end_at].respond_to?(:iso8601)

      parse_response(post("projects/#{@project_id}/schedules", {:schedules => [{:code_name => code_name, :payload => payload}.merge(options)]}))
    end

    def schedules_cancel(id)
      check_id(id)
      parse_response(post("projects/#{@project_id}/schedules/#{id}/cancel"))
    end

    def projects_get
      parse_response(get("projects/#{@project_id}"))
    end
  end
end
