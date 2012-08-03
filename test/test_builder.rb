require 'helpers'

class BuilderTest < IWNGTest

  def test_basic
    code = code_bundle do
      runtime 'ruby'
      name 'CHello'
      file 'test/hello.c'
      remote_build_command 'gcc hello.c'
      worker_code 'exec("./a.out")'
    end

    start = Time.now
    client.codes.create(code)
    puts "uploading finished in #{(Time.now - start).to_i} seconds"

    task = client.tasks.create('CHello')
    client.tasks.wait_for(task.id)

    assert_equal "hello\n", client.tasks.log(task.id)
  end

  def test_async
    code = code_bundle 'test/workers/with_build_command/with_build_command.worker'

    builder_task_id = client.codes.create(code, async: true)
    puts builder_task_id

    builder_task = client.tasks.wait_for(builder_task_id)
    puts builder_task

    assert_equal 'complete', builder_task.status

    task = client.tasks.create(code.name)
    puts task
    client.tasks.wait_for(task.id)

    log = client.tasks.log(task.id)
    assert_equal "hello\n", log
  end

end
