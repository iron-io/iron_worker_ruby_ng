require_relative 'helpers'

class CodeDeleteTest < IWNGTest
  def test_code_delete
    r = code = client.codes.create(code_bundle do
      name 'code_delete_test'
      worker_code 'puts "hello"'
    end)
    p r
    code_id1 = r.id
    task_id = client.tasks.create('code_delete_test').id
    client.tasks.wait_for(task_id)
    assert_equal "hello\n", client.tasks.log(task_id)

    client.codes.delete(code.id)

    assert_raises Rest::HttpError do
      r = client.codes.get(code.id)
      p r
    end

    assert_raises Rest::HttpError do
      task_id = client.tasks.create('code_delete_test').id
    end

    r = client.codes.create(code_bundle do
      name 'code_delete_test'
      worker_code 'puts "bye"'
    end)
    assert_not_equal(code_id1, r.id)
    task_id = client.tasks.create('code_delete_test').id
    client.tasks.wait_for(task_id)
    assert_equal "bye\n", client.tasks.log(task_id)
  end
end
