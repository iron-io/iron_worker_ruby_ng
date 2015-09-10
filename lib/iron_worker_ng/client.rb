require 'ostruct'
require 'base64'
require 'tmpdir'
require 'fileutils'

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

    def stacks_list
      @api.stacks_list
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

      options.merge!(stack:code.stack) if code.stack

      container_file = code.create_container

      if code.zip_package
        res = nil
        IronWorkerNG::Fetcher.fetch_to_file(code.zip_package) do |file|
          res = @api.codes_create(code.name, file, 'sh', '__runner__.sh', options)
        end
      elsif code.remote_build_command.nil? && (not code.full_remote_build)
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

      File.unlink(container_file) if code.zip_package.nil?

      res['_id'] = res['id']
      OpenStruct.new(res)
    end

    def codes_create_async(code, options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling codes.create_async with code='#{code.to_s}' and options='#{options.to_s}'"

      if options[:config] && options[:config].is_a?(Hash)
        options = options.dup
        options[:config] = options[:config].to_json
      end

      options.merge!(stack:code.stack) if code.stack

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

    def codes_patch(name, options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling codes.patch with name='#{name}' and options='#{options.to_s}'"

      code = codes.list(per_page: 100).find { |c| c.name == name }

      if code.nil?
        IronCore::Logger.error 'IronWorkerNG', "Can't find code with name='#{name}' to patch", IronCore::Error
      end

      patcher_code_name = name + (name[0 .. 0].upcase == name[0 .. 0] ? '::Patcher' : '::patcher')

      exec_dir = ::Dir.tmpdir + '/' + ::Dir::Tmpname.make_tmpname('iron-worker-ng-', 'exec')
      exec_file_name = exec_dir + '/patchcer.rb'

      FileUtils.mkdir_p(exec_dir)

      exec_file = File.open(exec_file_name, 'w')
      exec_file.write <<EXEC_FILE
# #{IronWorkerNG.full_version}

File.open('.gemrc', 'w') do |gemrc|
  gemrc.puts('gem: --no-ri --no-rdoc')
end

`gem install iron_worker_ng`

require 'iron_worker_ng'

client = IronWorkerNG::Client.new(JSON.parse(params[:client_options]))

original_code = client.codes.get(params[:code_id])
original_code_data = client.codes.download(params[:code_id])

`mkdir code`
original_code_zip = File.open('code/code.zip', 'w')
original_code_zip.write(original_code_data)
original_code_zip.close
`cd code && unzip code.zip && rm code.zip && cd ..`

patch_params = JSON.parse(params[:patch])
patch_params.each {|k, v| system("cat patch/\#{k} > code/\#{v}")}

code_container = IronWorkerNG::Code::Container::Zip.new

Dir['code/*'].each do |entry|
  code_container.add(entry[5 .. -1], entry)
end

code_container.close

res = client.api.codes_create(original_code.name, code_container.name, 'sh', '__runner__.sh', :config => original_code.config)

res['_id'] = res['id']
res = OpenStruct.new(res)

client.tasks.set_progress(iron_task_id, :msg => res.marshal_dump.to_json)
EXEC_FILE
      exec_file.close

      patcher_code = IronWorkerNG::Code::Base.new
      patcher_code.runtime = :ruby
      patcher_code.name = patcher_code_name
      patcher_code.exec(exec_file_name)
      options[:patch].keys.each {|v| patcher_code.file(v, 'patch')}
      patch_params = Hash[options[:patch].map {|k,v| [File.basename(k), v]}]

      patcher_container_file = patcher_code.create_container

      @api.codes_create(patcher_code_name, patcher_container_file, 'sh', '__runner__.sh', {})

      FileUtils.rm_rf(exec_dir)
      File.unlink(patcher_container_file)

      patcher_task = tasks.create(patcher_code_name, :code_id => code._id, :client_options => @api.options.to_json, patch: patch_params.to_json)
      patcher_task = tasks.wait_for(patcher_task._id)

      if patcher_task.status != 'complete'
        log = tasks.log(patcher_task._id)
        IronCore::Logger.error 'IronWorkerNG', "Error while patching worker\n" + log, IronCore::Error
      end

      res = JSON.parse(patcher_task.msg)
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

    def codes_pause_task_queue(code_id, options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling codes.pause_task_queue with code_id='#{code_id}' and options='#{options.to_s}'"

      res = @api.codes_pause_task_queue(code_id, options)
      OpenStruct.new(res)
    end

    def codes_resume_task_queue(code_id, options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling codes.resume_task_queue with code_id='#{code_id}' and options='#{options.to_s}'"

      res = @api.codes_resume_task_queue(code_id, options)
      OpenStruct.new(res)
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

      if block_given?
        @api.tasks_log(task_id) { |chunk| yield(chunk) }
      else
        @api.tasks_log(task_id)
      end
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

      @api.schedules_list(options)['schedules'].map { |s| OpenStruct.new(s.merge('_id' => s['id'])) }
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

    def schedules_update(id, options = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling schedules.update with id='#{id}', options='#{options.to_s}'"

      res = @api.schedules_update(id, options)

      OpenStruct.new(res)
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

    def clusters_list
      IronCore::Logger.debug 'IronWorkerNG', "Calling clusters.list"
      res = @api.clusters_list
      res['clusters'].map { |s| OpenStruct.new(s.merge('_id' => s['id'])) }
    end

    def clusters_get(id)
      IronCore::Logger.debug 'IronWorkerNG', "Calling projects.get"
      res = @api.clusters_get(id)['cluster']
      res['_id'] = res['id']
      OpenStruct.new(res)
    end

    def clusters_credentials(id)
      IronCore::Logger.debug 'IronWorkerNG', "Calling projects.get"
      res = @api.clusters_credentials(id)['cluster']
      res['_id'] = res['id']
      OpenStruct.new(res)
    end

    def clusters_create(params = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling clusters.create with params='#{params.to_s}'"
      res = @api.clusters_create(params)
      OpenStruct.new(res)
    end

    def clusters_update(cluster_id, params = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling clusters.update with params='#{params.to_s}'"
      res = @api.clusters_update(cluster_id, params)
      OpenStruct.new(res)
    end

    def clusters_delete(cluster_id)
      IronCore::Logger.debug 'IronWorkerNG', "Calling clusters.delete with cluster_id='#{cluster_id}'"
      res = @api.clusters_delete(cluster_id)
      OpenStruct.new(res)
    end

    def clusters_share(cluster_id, params = {})
      IronCore::Logger.debug 'IronWorkerNG', "Calling clusters.share with params='#{params.to_s}'"
      res = @api.clusters_share(cluster_id, params)
      OpenStruct.new(res)
    end

    def clusters_shared_list
      IronCore::Logger.debug 'IronWorkerNG', "Calling clusters.shared.list"
      res = @api.clusters_shared_list
      res['clusters'].map { |s| OpenStruct.new(s.merge('_id' => s['id'])) }
    end

    def params_for_legacy(code_name, params = {})
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
