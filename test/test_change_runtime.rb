require 'helpers'

class ChangeRuntimeTest < IWNGTest

  # Alexander S.	
  # btw looks like its a bug:
  # 1) upload worker with any name
  # 2) upload worker with same name and different runtime
  # 3) launch it and gaze on error

  def ruby_worker(code_name)
    client.codes_create( code_bundle do
                           name code_name
                           worker_code 'puts "hello"'
                         end )

    task = client.tasks.create(code_name)
    client.tasks.wait_for task.id

    assert_equal "hello\n", client.tasks.log(task.id)
  end

  def sh_worker(code_name)
    code = IronWorkerNG::Code.new do
      runtime 'binary'
      name code_name
      exec(Tempfile.open('sh') do |f|
             f << 'echo "hello"'
           end.path)
    end

    task = client.tasks.create(code_name)
    client.tasks.wait_for task.id

    assert_equal "hello\n", client.tasks.log(task.id)
  end

  def test_sh_to_ruby
    sh_worker 'sh_to_ruby'
    ruby_worker 'sh_to_ruby'
  end

  def test_ruby_to_sh
    ruby_worker 'ruby_to_sh'
    sh_worker 'ruby_to_sh'
  end

end
