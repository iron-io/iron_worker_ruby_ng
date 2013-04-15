module IronWorkerNG
  class CLI
    LOG_ENTRY = '        '
    LOG_GROUP = '------> '

    def initialize
      @client = nil

      @config = nil
      @env = nil
      @project_id = nil
    end

    def beta?
      beta = ENV['IRON_BETA']

      beta == '1' || beta == 1 || beta == 'true' || beta == true || beta == 'beta'
    end

    def config=(config)
      @client = nil

      @config = config
    end

    def env=(env)
      @client = nil

      @env = env
    end

    def project_id=(project_id)
      @client = nil

      @project_id = project_id
    end

    def log(msg)
      IronCore::Logger.info 'IronWorkerNG', msg
    end

    def log_group(msg)
      IronCore::Logger.info 'IronWorkerNG', LOG_GROUP + msg
    end

    def client
      if @client.nil?
        log_group "Creating client"

        @client = IronWorkerNG::Client.new(:config => @config, :env => @env, :project_id => @project_id)

        project = client.projects.get

        log "Project '#{project.name}' with id='#{project._id}'"
      end

      @client
    end

    def upload(name, params, options)
      client

      log_group "Creating code package"

      code = IronWorkerNG::Code::Base.new(name)

      code.name(params[:name]) unless params[:name].nil?

      code.full_remote_build = params[:full_remote_build] unless params[:full_remote_build].nil?

      log "Code package name is '#{code.name}'"
      log "Max concurrency set to '#{options[:max_concurrency]}'" unless options[:max_concurrency].nil?
      log "Retries set to '#{options[:retries]}'" unless options[:retries].nil?
      log "Retries delay set to '#{options[:retries_delay]}'" unless options[:retries_delay].nil?
      log "Host set to '#{options[:host]}'" unless options[:host].nil?

      if options[:worker_config]
        log "Loading worker_config at #{options[:worker_config]}"
        c = IO.read(options[:worker_config])
        options[:config] = c
      end

      if code.remote_build_command || code.full_remote_build
        log_group "Uploading and building code package '#{code.name}'"
      else
        log_group "Uploading code package '#{code.name}'"
      end

      if (params[:async] || params['async']) && code.remote_build_command
        builder_task_id = client.codes.create_async(code, options)

        log 'Code package is building'
        log "Check 'https://hud.iron.io/tq/projects/#{client.api.project_id}/jobs/#{builder_task_id}' for more info"
      else
        code_id = client.codes.create(code, options)._id
        code_info = client.codes.get(code_id)

        log "Code package uploaded with id='#{code_id}' and revision='#{code_info.rev}'"
        log "Check 'https://hud.iron.io/tq/projects/#{client.api.project_id}/code/#{code_id}' for more info"
      end
    end

    def queue(name, params, options)
      client

      log_group "Queueing task"

      id = client.tasks.create(name, params[:payload] || params['payload'], options)._id

      log "Code package '#{name}' queued with id='#{id}'"
      log "Check 'https://hud.iron.io/tq/projects/#{client.api.project_id}/jobs/#{id}' for more info"

      if options[:wait] == true
        getlog(id, {}, {:wait => true})
      end
    end

    def schedule(name, params, options)
      client

      log_group "Scheduling task"

      id = client.schedules.create(name, params[:payload] || params['payload'], options)._id

      log "Code package '#{name}' scheduled with id='#{id}'"
      log "Check 'https://hud.iron.io/tq/projects/#{client.api.project_id}/scheduled_jobs/#{id}' for more info"
    end

    def retry(task_id, params, options)
      client

      log_group "Retrying task with id='#{task_id}'"

      retry_task_id = client.tasks.retry(task_id, options)._id

      log "Task retried with id='#{retry_task_id}'"
      log "Check 'https://hud.iron.io/tq/projects/#{client.api.project_id}/jobs/#{retry_task_id}' for more info"

      if options[:wait] == true
        getlog(retry_task_id, {}, {:wait => true})
      end
    end

    def getlog(task_id, params, options)
      client

      wait = options[:wait] || options['wait']

      log_group "Getting log for task with id='#{task_id}'"

      log = ''

      if wait
        begin
          log = client.tasks.log(task_id)
        rescue
        end
      else
        log = client.tasks.log(task_id)
      end

      print log

      if wait
        client.tasks.wait_for(task_id) do |task|
          if task.status == 'running'
            begin
              next_log = client.tasks.log(task_id)
              print next_log[log.length .. - 1]
              log = next_log
            rescue
            end
          end
        end

        begin
          next_log = client.tasks.log(task_id)
          print next_log[log.length .. - 1]
        rescue
        end
      end
    end

    def run(name, params, options)
      log_group "Creating code package"

      code = IronWorkerNG::Code::Base.new(name)

      log "Code package name is '#{code.name}'"

      log_group "Running '#{code.name}'"

      code.run(params[:payload] || params['payload'])
    end

    def install(name, params, options)
      log_group "Installing dependencies for code package with name='#{name}'"

      code = IronWorkerNG::Code::Base.new(name)

      code.install
    end

    def webhook(name, params, options)
      client

      log_group 'Generating code package webhook'

      log 'You can invoke your worker by POSTing to the following URL'
      log client.api.url("projects/#{client.api.project_id}/tasks/webhook?code_name=#{name}&oauth=#{client.api.token}")
    end

    def info_code(name, params, options)
      client

      log_group 'Getting code package info'

      codes = client.codes.list({:all => true})
      code = codes.find { |code| code.name == name }

      unless code
        log "Code package with name='#{name}' not found"
        exit 1
      end

      data = []
      data << ['id', code._id]
      data << ['name', code.name]
      data << ['revision', code.rev]
      data << ['uploaded', parse_time(code.latest_change) || '-']
      data << ['max concurrency', code.max_concurrency || '-']
      data << ['retries', code.retries || '-']
      data << ['retries delay', code.retries_delay || '-']
      data << ['info', "https://hud.iron.io/tq/projects/#{client.api.project_id}/code/#{code._id}"]
      data << ['tasks info', "https://hud.iron.io/tq/projects/#{client.api.project_id}/jobs/#{code._id}/activity"]

      display_table(data)
    end

    def info_task(task_id, params, options)
      client

      log_group 'Getting task info'

      task = client.tasks.get(task_id)

      data = []
      data << ['id', task._id]
      data << ['code package', task.code_name]
      data << ['code revision', task.code_rev]
      data << ['status', task.status]
      data << ['priority', task.priority || 2]
      data << ['queued', parse_time(task.created_at) || '-']
      data << ['started', parse_time(task.start_time) || '-']
      data << ['finished', parse_time(task.end_time) || '-']
      data << ['payload', task.payload]
      data << ['info', "https://hud.iron.io/tq/projects/#{client.api.project_id}/jobs/#{task._id}"]

      display_table(data)
    end

    def info_schedule(schedule_id, params, options)
      client

      log_group 'Getting schedule info'

      schedule = client.schedules.get(schedule_id)

      data = []
      data << ['id', schedule._id]
      data << ['code package', schedule.code_name]
      data << ['status', schedule.status]
      data << ['created', parse_time(schedule.created_at) || '-']
      data << ['next start', parse_time(schedule.next_start) || '-']
      data << ['run count', schedule.run_count || '-']
      data << ['payload', schedule.payload]
      data << ['info', "https://hud.iron.io/tq/projects/#{client.api.project_id}/scheduled_jobs/#{schedule._id}"]

      display_table(data)
    end

    def parse_time(s)
      t = Time.parse(s)

      return nil if t == Time.utc(1)

      t
    end

    def display_table(t)
      t.each do |r|
        log sprintf('%-16s %s', r[0], r[1])
      end
    end
  end
end
