gem 'test-unit'
require 'test/unit'
require_relative 'helpers'

class BasicTest < IWNGTest
  def test_build_worker
    code = IronWorkerNG::Code::Ruby.new('build_worker.rb')
    code.merge_gem 'iron_worker_ng'
    code.merge_file 'workers/hello.go'
    code.merge_file 'workers/hello_go.worker'
    #code.merge_exec(File.dirname(__FILE__) + '/hello.rb')
    client.codes_create(code)
    task_id = client.tasks.create('BuildWorker',
                                  client.api.options.merge(:name => "HelloGo")).id

    task = client.tasks_wait_for(task_id)
    assert task
    assert task.id == task_id
    assert_equal "complete", task.status

    log = client.tasks_log(task_id)
    puts "LOG START"
    puts log
    puts "LOG END"

    puts 'Running HelloGo...'
    go_task_id = client.tasks.create("HelloGo").id
    task = client.tasks_wait_for(go_task_id)
    assert_equal "complete", task.status
    log = client.tasks_log(go_task_id)
    puts "LOG START"
    puts log
    puts "LOG END"
  end
end
