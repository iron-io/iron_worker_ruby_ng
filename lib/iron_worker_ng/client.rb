require 'ostruct'
require 'base64'

require 'iron_worker_ng/api_client'

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
        super(name, *args, &block)
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

    def options
      @api.options
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
        super(name, *args, &block)
      end
    end

    def codes_list(options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling codes.list with options='#{options.to_s}'"

      all = options[:all] || options['all']

      if all
        result = []

        page = options[:page] || options['page'] || 0
        per_page = options[:per_page] || options['per_page'] || 100

        while true
          next_codes = codes_list(options.merge({:page => page}).delete_if { |name| name == :all || name == 'all' })

          result += next_codes

          break if next_codes.length != per_page
          page += 1
        end

        result
      else
        @api.codes_list(options)['codes'].map { |c| OpenStruct.new(c.merge('_id' => c['id'])) }
      end
    end

    def codes_get(code_id)
      IronCore::Logger.debug 'IronWorkerNG', "Calling codes.get with code_id='#{code_id}'"

      c = @api.codes_get(code_id)
      c['_id'] = c['id']
      OpenStruct.new(c)
    end

    def codes_create(code, options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling codes.create with code='#{code.to_s}' and options='#{options.to_s}'"

      if options[:config] && options[:config].is_a?(Hash)
        options = options.dup
        options[:config] = options[:config].to_json
      end

      container_file = code.create_container

      if code.remote_build_command.nil? && (not code.full_remote_build)
        res = @api.codes_create(code.name, container_file, 'sh', '__runner__.sh', options)
      else
        builder_code_name = code.name + (code.name[0 .. 0].upcase == code.name[0 .. 0] ? '::Builder' : '::builder')

        @api.codes_create(builder_code_name, container_file, 'sh', '__runner__.sh', options)

        builder_task = tasks.create(builder_code_name, :code_name => code.name, :client_options => @api.options.to_json, :codes_create_options => options.to_json)

        builder_task = tasks.wait_for(builder_task._id)

        if builder_task.status != 'complete'
          log = tasks.log(builder_task._id)

          File.unlink(container_file)

          IronCore::Logger.error 'IronWorkerNG', "Error while remote building worker\n" + log, IronCore::Error
        end

        res = JSON.parse(builder_task.msg)
      end

      File.unlink(container_file)

      res['_id'] = res['id']
      OpenStruct.new(res)
    end

    def codes_create_async(code, options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling codes.create_async with code='#{code.to_s}' and options='#{options.to_s}'"

      if options[:config] && options[:config].is_a?(Hash)
        options = options.dup
        options[:config] = options[:config].to_json
      end

      container_file = code.create_container

      if code.remote_build_command.nil? && (not code.full_remote_build)
        res = @api.codes_create(code.name, container_file, 'sh', '__runner__.sh', options)
      else
        builder_code_name = code.name + (code.name[0 .. 0].upcase == code.name[0 .. 0] ? '::Builder' : '::builder')

        @api.codes_create(builder_code_name, container_file, 'sh', '__runner__.sh', options)

        builder_task = tasks.create(builder_code_name, :code_name => code.name, :client_options => @api.options.to_json, :codes_create_options => options.to_json)

        File.unlink(container_file)

        return builder_task._id
      end

      File.unlink(container_file)

      res['_id'] = res['id']
      OpenStruct.new(res)
    end

    def codes_delete(code_id)
      IronCore::Logger.debug 'IronWorkerNG', "Calling codes.delete with code_id='#{code_id}'"

      @api.codes_delete(code_id)

      true
    end

    def codes_revisions(code_id, options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling codes.revisions with code_id='#{code_id}' and options='#{options.to_s}'"

      @api.codes_revisions(code_id, options)['revisions'].map { |c| OpenStruct.new(c.merge('_id' => c['id'])) }
    end

    def codes_download(code_id, options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling codes.download with code_id='#{code_id}' and options='#{options.to_s}'"

      @api.codes_download(code_id, options)
    end

    def tasks_list(options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling tasks.list with options='#{options.to_s}'"

      @api.tasks_list(options)['tasks'].map { |t| OpenStruct.new(t.merge('_id' => t['id'])) }
    end

    def tasks_get(task_id)
      IronCore::Logger.debug 'IronWorkerNG', "Calling tasks.get with task_id='#{task_id}'"

      t = @api.tasks_get(task_id)
      t['_id'] = t['id']
      OpenStruct.new(t)
    end

    def tasks_create(code_name, params = {}, options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling tasks.create with code_name='#{code_name}', params='#{params.to_s}' and options='#{options.to_s}'"

      res = @api.tasks_create(code_name, params.is_a?(String) ? params : params.to_json, options)

      t = res['tasks'][0]
      t['_id'] = t['id']
      OpenStruct.new(t)
    end

    def tasks_create_legacy(code_name, params = {}, options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling tasks.create_legacy with code_name='#{code_name}', params='#{params.to_s}' and options='#{options.to_s}'"

      res = @api.tasks_create(code_name, params_for_legacy(code_name, params), options)

      t = res['tasks'][0]
      t['_id'] = t['id']
      OpenStruct.new(t)
    end

    def tasks_cancel(task_id)
      IronCore::Logger.debug 'IronWorkerNG', "Calling tasks.cancel with task_id='#{task_id}'"

      @api.tasks_cancel(task_id)

      true
    end

    def tasks_cancel_all(code_id)
      IronCore::Logger.debug 'IronWorkerNG', "Calling tasks.cancel_all with code_id='#{code_id}'"

      @api.tasks_cancel_all(code_id)

      true
    end

    def tasks_log(task_id)
      IronCore::Logger.debug 'IronWorkerNG', "Calling tasks.log with task_id='#{task_id}'"

      @api.tasks_log(task_id)
    end

    def tasks_set_progress(task_id, options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling tasks.set_progress with task_id='#{task_id}' and options='#{options.to_s}'"

      @api.tasks_set_progress(task_id, options)

      true
    end

    def tasks_wait_for(task_id, options = {}, &block)
      IronCore::Logger.debug 'IronWorkerNG', "Calling tasks.wait_for with task_id='#{task_id}' and options='#{options.to_s}'"

      options[:sleep] ||= options['sleep'] || 5

      task = tasks_get(task_id)

      while task.status == 'queued' || task.status == 'running'
        block.call(task) unless block.nil?
        sleep options[:sleep]
        task = tasks_get(task_id)
      end

      task
    end

    def tasks_retry(task_id, options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling tasks.retry with task_id='#{task_id}' and options='#{options.to_s}'"

      res = @api.tasks_retry(task_id, options)

      t = res['tasks'][0]
      t['_id'] = t['id']
      OpenStruct.new(t)
    end

    def schedules_list(options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling schedules.list with options='#{options.to_s}'"

      @api.schedules_list(options)['schedules'].map { |s| OpenStruct.new(s) }
    end

    def schedules_get(schedule_id)
      IronCore::Logger.debug 'IronWorkerNG', "Calling schedules.get with schedule_id='#{schedule_id}"

      s = @api.schedules_get(schedule_id)
      s['_id'] = s['id']
      OpenStruct.new(s)
    end

    def schedules_create(code_name, params = {}, options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling schedules.create with code_name='#{code_name}', params='#{params.to_s}' and options='#{options.to_s}'"

      res = @api.schedules_create(code_name, params.is_a?(String) ? params : params.to_json, options)

      s = res['schedules'][0]
      s['_id'] = s['id']
      OpenStruct.new(s)
    end

    def schedules_create_legacy(code_name, params = {}, options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling schedules.create_legacy with code_name='#{code_name}', params='#{params.to_s}' and options='#{options.to_s}'"

      res = @api.schedules_create(code_name, params_for_legacy(code_name, params), options)

      s = res['schedules'][0]
      s['_id'] = s['id']
      OpenStruct.new(s)
    end

    def schedules_cancel(schedule_id)
      IronCore::Logger.debug 'IronWorkerNG', "Calling schedules.cancel with schedule_id='#{schedule_id}"

      @api.schedules_cancel(schedule_id)

      true
    end

    def projects_get
      IronCore::Logger.debug 'IronWorkerNG', "Calling projects.get"

      res = @api.projects_get

      res['_id'] = res['id']
      OpenStruct.new(res)
    end

    def params_for_legacy(code_name, params)
      if params.is_a?(String)
        params = JSON.parse(params)
      end

      attrs = {}

      params.keys.each do |k|
        attrs['@' + k.to_s] = params[k]
      end

      attrs = attrs.to_json

      {:class_name => code_name, :attr_encoded => Base64.encode64(attrs), :sw_config => {:project_id => project_id, :token => token}}.to_json
    end
  end
end
