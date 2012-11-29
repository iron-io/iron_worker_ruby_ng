require_relative 'helpers'

class FetcherTest < IWNGTest

  HELLO = 'https://raw.github.com/iron-io/iron_worker_ruby_ng/master/test/hello.rb'

  def test_basic
    code = code_bundle { exec HELLO }
    client.codes.create(code)
    task_id = client.tasks.create(code.name).id
    client.tasks.wait_for(task_id)
    assert_equal "hello\n", client.tasks.log(task_id)      
  end

  def test_with_workerfile
    Tempfile.open(['', '.worker']) do |f|
      f << "file '#{File.basename(f.path)}'\n"
      f << "exec '#{HELLO}'\n"
      f.close

      code = IronWorkerNG::Code::Base.new(workerfile: f.path)

      client.codes.create code
      task_id = client.tasks.create(code.name).id
      client.tasks.wait_for(task_id)
      assert_equal "hello\n", client.tasks.log(task_id)      
    end
  end

end
