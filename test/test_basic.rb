require 'helpers'

class BasicTest < IWNGTest
  def _test_basic
    code = IronWorkerNG::Code::Ruby.new('test_basic')
    code.merge_worker(File.dirname(__FILE__) + '/hello.rb')
    client.codes_create(code)
    task_id = client.tasks_create('test_basic').id
    client.tasks_wait_for(task_id)
    log = client.tasks_log(task_id)
    assert_equal( "hello\n", log, "worker stdout is in log" )
  end

  def test_symlinks
    Dir.unlink './test/data/dir1/dir2' if
      Dir.exist? './test/data/dir1/dir2'
    Dir.chdir('test/data/dir1') do
      File.symlink('./test/data/dir2', 'dir2')
    end

    code = code_bundle 'test_symlinks' do
      merge_dir('data/dir1', 'data')
      worker 'puts File.read("dir1/dir2/test")'
    end

    puts code.create_zip

    File.unlink 'test/data/dir1/dir2'

    assert true
  end

end
