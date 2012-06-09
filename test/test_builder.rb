gem 'test-unit'
require 'test/unit'
require_relative 'helpers'

class BuilderTest < IWNGTest

  def test_build_worker

    main_file = "hello.go"
    name = "HelloGo"

    code = IronWorkerNG::Code::Ruby.new('build_worker.rb')
    code.merge_gem 'iron_worker_ng'
    code.merge_file "workers/#{main_file}"
    code.merge_file 'workers/hello_go.worker'
    #code.merge_exec(File.dirname(__FILE__) + '/hello.rb')
    client.codes_create(code)

    task_id = client.tasks.create('BuildWorker',
                                  client.api.options.merge(
                                      :name => name,
                                      :build_command => "go build #{main_file}",
                                      :exec => 'hello'
                                  )).id

    task = client.tasks_wait_for(task_id)
    assert task
    assert task.id == task_id
    assert_equal "complete", task.status

    log = client.tasks_log(task_id)
    puts "LOG START"
    puts log
    puts "LOG END"

    puts "Running #{name}..."
    go_task_id = client.tasks.create(name).id
    task = client.tasks_wait_for(go_task_id)
    assert_equal "complete", task.status
    log = client.tasks_log(go_task_id)
    puts "LOG START"
    puts log
    puts "LOG END"
  end

  def test_ruby_build_from_github

    # Usage would be via cli:
    # iron_worker upload??? https://github.com/iron-io/iron_worker_examples/blob/master/ruby_ng/hello_worker/hello.worker

    worker_file_url = "https://github.com/iron-io/iron_worker_examples/blob/master/ruby_ng/worker101/worker101.worker"
    name = "RubyWorker101"

    remote_build(name, worker_file_url)

    # Now let's try queueing up a task for it
    puts "Running #{name}..."
    go_task_id = client.tasks.create(name, 'query' => 'bieber').id
    task = client.tasks_wait_for(go_task_id)
    assert_equal "complete", task.status
    log = client.tasks_log(go_task_id)
    puts "LOG START"
    puts log
    puts "LOG END"
  end

  def remote_build(name, worker_file_url)
    code = IronWorkerNG::Code::Ruby.new('build_worker.rb')
    code.merge_gem 'iron_worker_ng'
    client.codes_create(code)

    task_id = client.tasks.create('BuildWorker',
                                  client.api.options.merge(
                                      :name => name,
                                      :worker_file_url => worker_file_url
                                  )).id

    task = client.tasks_wait_for(task_id)
    assert task
    assert task.id == task_id
    log = client.tasks_log(task_id)
    puts "LOG START"
    puts log
    puts "LOG END"

    assert_equal "complete", task.status

  end


  # This one not only gets the code from github, but compiles it too.
  def test_go_build_from_github

    # Usage would be via cli:
    # iron_worker upload??? https://github.com/iron-io/iron_worker_examples/blob/master/ruby_ng/hello_worker/hello.worker

    worker_file_url = "https://github.com/iron-io/iron_worker_examples/blob/master/go/hello_worker/hello.worker"
    name = "HelloGoGithub"

    remote_build(name, worker_file_url)

    # Try queuing up a task for it
    puts "Running #{name}..."
    go_task_id = client.tasks.create(name).id
    task = client.tasks_wait_for(go_task_id)
    log = client.tasks_log(go_task_id)
    puts "LOG START"
    puts log
    puts "LOG END"
    assert_equal "complete", task.status
  end

end
