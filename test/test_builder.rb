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

    puts code.create_zip

    start = Time.now
    client.codes.create(code)
    puts "uploading finished in #{(Time.now - start).to_i} seconds"

    task = client.tasks.create('CHello')
    client.tasks.wait_for(task.id)

    assert_equal "hello\n", client.tasks.log(task.id)
  end

end
