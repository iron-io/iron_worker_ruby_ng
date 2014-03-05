require_relative 'helpers.rb'

class RubyRunnerTest < IWNGTest

  def test_script
    code = code_bundle :exec => 'test/workers/ruby_runner_test_script.rb'
    client.codes_create(code)
    task_id = client.tasks_create('ruby_runner_test_script',
                                  :a => 1, :b => 2).id
    client.tasks_wait_for(task_id)
    resp = JSON.parse client.tasks_log(task_id)

    puts resp.to_s

    assert_equal( { "a" => 1, "b" => 2 }, resp['params'],
                  "correct params" )

    assert_equal resp['params'], JSON.parse(resp['payload']),
                 "params are parsed payload"

    assert resp['iron_task_id'] =~ /[0-9a-f]{24}/,
           "iron_task_id available"

    assert resp['indifferent_access'], "indifferent access works"
  end

  def test_class
    code = code_bundle do
      exec 'test/workers/ruby_runner_test_class.rb', 'RubyWorker'
    end
    client.codes_create(code)
    task_id = client.tasks_create('ruby_runner_test_class',
                                  :a => 1, :b => 2).id
    client.tasks_wait_for(task_id)

    assert_equal( { 'a' => 1, 'b' => 2 },
                  JSON.parse( client.tasks_log(task_id) ),
                  "correct output" )
  end

  def test_locale_bug
    code = code_bundle do
      exec 'test/workers/locale_csv_worker.rb'
      file 'test/workers/file.csv'
    end
    client.codes_create(code)
    task = client.tasks_create('locale_csv_worker')
    client.tasks_wait_for(task.id)
    task = client.tasks_get(task.id)
    assert_equal "complete",  task.status
    assert_equal( "All good\n",
                  client.tasks_log(task.id),
                  "correct output" )
  end

end
