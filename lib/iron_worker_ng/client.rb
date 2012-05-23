require 'ostruct'
require 'json'

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

    def initialize(options = {}, &block)
      @api = IronWorkerNG::APIClient.new(options)

      unless block.nil?
        instance_eval(&block)
      end
    end

    def token
      @api.token
    end

    def project_id
      @api.project_id
    end

    def method_missing(name, *args, &block)
      if args.length == 0
        IronWorkerNG::ClientProxyCaller.new(self, name)
      else
        super
      end
    end

    def codes_list(options = {})
      @api.codes_list(options)['codes'].map { |c| OpenStruct.new(c) }
    end

    def codes_get(code_id)
      OpenStruct.new(@api.codes_get(code_id))
    end

    def codes_create(code)
      zip_file = code.create_zip
      res = @api.codes_create(code.name, zip_file, 'sh', '__runner__.sh')
      File.unlink(zip_file)

      OpenStruct.new(res)
    end

    def codes_delete(code_id)
      @api.codes_delete(code_id)

      true
    end

    def codes_revisions(code_id, options = {})
      @api.codes_revisions(code_id, options)['revisions'].map { |c| OpenStruct.new(c) }
    end

    def codes_download(code_id, options = {})
      @api.codes_download(code_id, options)
    end

    def tasks_list(options = {})
      @api.tasks_list(options)['tasks'].map { |t| OpenStruct.new(t) }
    end

    def tasks_get(task_id)
      OpenStruct.new(@api.tasks_get(task_id))
    end

    def tasks_create(code_name, params = {}, options = {})
      res = @api.tasks_create(code_name, params.class == String ? params : params.to_json, options)

      OpenStruct.new(res['tasks'][0])
    end

    def tasks_cancel(task_id)
      @api.tasks_cancel(task_id)

      true
    end

    def tasks_cancel_all(code_id)
      @api.tasks_cancel_all(code_id)

      true
    end

    def tasks_log(task_id)
      @api.tasks_log(task_id)
    end

    def tasks_set_progress(task_id, options = {})
      @api.tasks_set_progress(task_id, options)

      true
    end

    def tasks_wait_for(task_id, options = {})
      options[:sleep] ||= options['sleep'] || 5

      task = tasks_get(task_id)

      while task.status == 'queued' || task.status == 'running'
        yield task if block_given?
        sleep options[:sleep]
        task = tasks_get(task_id)
      end

      task
    end

    def schedules_list(options = {})
      @api.schedules_list(options)['schedules'].map { |s| OpenStruct.new(s) }
    end

    def schedules_get(schedule_id)
      OpenStruct.new(@api.schedules_get(schedule_id))
    end

    def schedules_create(code_name, params = {}, options = {})
      res = @api.schedules_create(code_name, params.class == String ? params : params.to_json, options)

      OpenStruct.new(res['schedules'][0])
    end

    def schedules_cancel(schedule_id)
      @api.schedules_cancel(schedule_id)

      true
    end
  end
end
