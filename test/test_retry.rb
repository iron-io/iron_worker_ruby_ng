require_relative 'helpers'

class RetryTest < IWNGTest

  def test_basic
    code = IronWorkerNG::Code::Base.new do
      name 'hello'
      exec 'test/hello.rb'
    end
    client.codes.create(code)

    # queue
    task_id = client.tasks.create('hello').id
    client.tasks.wait_for(task_id)

    # retry
    task_id = client.tasks.retry(task_id).id
    client.tasks.wait_for(task_id)

    assert_equal "hello\n", client.tasks.log(task_id)
  end

end
