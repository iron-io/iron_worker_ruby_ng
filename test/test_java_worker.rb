require 'helpers'

class JavaWorkerTest < IWNGTest

  def test_hello
    code = IronWorkerNG::Code.new do
      runtime 'java'
      name 'JavaHello'
      exec 'test/hello.jar'
    end
    client.codes_create(code)

    task = client.tasks_create('JavaHello')

    client.tasks_wait_for(task.id)

    assert_equal "hello\n", client.tasks.log(task.id),
                 'correct output'
  end

end
