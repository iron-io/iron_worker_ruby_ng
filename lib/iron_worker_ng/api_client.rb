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

      super('iron', 'worker', options, default_options, [:project_id, :token, :jwt, :api_version])

      #puts "nhp.proxy yo #{rest.wrapper.http.proxy_uri}" if defined? Net::HTTP::Persistent
      #puts "RestClient.proxy yo #{RestClient.proxy}" if defined? RestClient
      #puts "InternalClient.proxy yo #{Rest::InternalClient.proxy}" if defined? Rest::InternalClient

      IronCore::Logger.error 'IronWorkerNG', "Token is not set", IronCore::Error if @token.nil? && @jwt.nil?

      check_id(@project_id, 'project_id')
    end

    def headers
      if !@jwt.nil?
        super.merge({'Authorization' => "JWT #{@token}"})
      else
        super.merge({'Authorization' => "OAuth #{@token}"})
      end
    end

    def base_url
      super + @api_version.to_s + '/'
    end

    def stacks_list
      parse_response(get("stacks"))
    end

    def codes_list(options = {})
      parse_response(get("projects/#{@project_id}/codes", options))
    end

    def codes_get(id)
      check_id(id)
      parse_response(get("projects/#{@project_id}/codes/#{id}"))
    end

    def codes_create(name, file, runtime, runner, options)
      file_instance = file.to_s.strip ==  '' ? '' : File.new(file, 'rb')
      options = {:name => name, :runtime => runtime, :file_name => runner}.merge(options)
      parse_response(post_file("projects/#{@project_id}/codes", :file, file_instance, :data, options))
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

    def codes_pause_task_queue(id, options = {})
      check_id(id)
      parse_response(post("projects/#{@project_id}/codes/#{id}/pause_task_queue", options))
    end

    def codes_resume_task_queue(id, options = {})
      check_id(id)
      parse_response(post("projects/#{@project_id}/codes/#{id}/resume_task_queue", options))
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

    def tasks_cancel_all(id)
      check_id(id)
      parse_response(post("projects/#{@project_id}/codes/#{id}/cancel_all"))
    end

    def tasks_log(id)
      check_id(id)
      if block_given?
        stream_get("projects/#{@project_id}/tasks/#{id}/log") do |chunk|
          yield chunk
        end
      else
        parse_response(get("projects/#{@project_id}/tasks/#{id}/log"), false)
      end
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

    def schedules_update(id, options = {})
      check_id(id)
      parse_response(put("projects/#{@project_id}/schedules/#{id}", options))
    end

    def schedules_cancel(id)
      check_id(id)
      parse_response(post("projects/#{@project_id}/schedules/#{id}/cancel"))
    end

    def projects_get
      parse_response(get("projects/#{@project_id}"))
    end

    def clusters_list
      parse_response(get("clusters"))
    end

    def clusters_get(cluster_id)
      parse_response(get("clusters/#{cluster_id}"))
    end

    def clusters_credentials(cluster_id)
      parse_response(get("clusters/#{cluster_id}/credentials"))
    end

    def clusters_create(options = {})
      parse_response(post("clusters", options))
    end

    def clusters_update(cluster_id, options = {})
      parse_response(put("clusters/#{cluster_id}", options))
    end

    def clusters_delete(cluster_id)
      parse_response(delete("clusters/#{cluster_id}"))
    end

    def clusters_share(cluster_id, options = {})
      parse_response(post("clusters/#{cluster_id}/share", options))
    end

    def clusters_shared_list
      parse_response(get("clusters/shared"))
    end

    def clusters_unshare(cluster_id, user_id)
      parse_response(post("clusters/#{cluster_id}/unshare/#{user_id}"))
    end
  end
end
