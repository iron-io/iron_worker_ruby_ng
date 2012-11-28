require_relative 'helpers'

class CodeDeleteTest < IWNGTest
  def test_basic
    code = client.codes.create(code_bundle do
                                 name 'code_delete_test'
                                 worker_code 'puts "hello"'
                               end)
    task_id = client.tasks.create('code_delete_test').id
    client.tasks.wait_for(task_id)
    assert_equal "hello\n", client.tasks.log(task_id)

    client.codes.delete(code.id)

    client.codes.create(code_bundle do
                          name 'code_delete_test'
                          worker_code 'puts "bye"'
                        end)
    task_id = client.tasks.create('code_delete_test').id
    client.tasks.wait_for(task_id)
    assert_equal "bye\n", client.tasks.log(task_id)
  end
end
