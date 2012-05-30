require 'time'

require 'iron_core'

module IronWorkerNG
  class APIClient < IronCore::Client
    AWS_US_EAST_HOST = 'worker-aws-us-east-1.iron.io'

    def initialize(options = {})
      super('worker', options)

      load_from_hash(:scheme => 'https',
                     :host => IronWorkerNG::APIClient::AWS_US_EAST_HOST,
                     :port => 443,
                     :api_version => 2,
                     :user_agent => IronWorkerNG.full_version)

      if (not @token) || (not @project_id)
        IronCore::Logger.error 'IronWorkerNG', 'Both token and project_id must be specified' 
        raise IronCore::IronError.new('Both token and project_id must be specified')
      end
    end

    def codes_list(options = {})
      parse_response(get("projects/#{@project_id}/codes", options))
    end

    def codes_get(id)
      parse_response(get("projects/#{@project_id}/codes/#{id}"))
    end

    def codes_create(name, file, runtime, runner, options)
      parse_response(post_file("projects/#{@project_id}/codes", File.new(file, 'rb'), {:name => name, :runtime => runtime, :file_name => runner}.merge(options)))
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
