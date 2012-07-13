require 'helpers'
require 'zip/zip'

class CommonFeaturesTest < IWNGTest

  def test_merge_file
    code = code_bundle do
      merge_file('test/data/dir2/test', 'test/data/dir2')
      merge_exec('test/hello.rb')
    end

    inspect_zip(code) do |zip|
      assert zip.find_entry('test/data/dir2/test')
    end
  end

  def test_merge_file_no_dest
    code = code_bundle do
      merge_file('Gemfile')
      merge_exec('test/hello.rb')
    end

    inspect_zip(code) do |zip|
      assert zip.find_entry('Gemfile')
    end
  end

  def test_missing_file
    assert_raise IronCore::Error, "should check if merged file exists" do
      code_bundle do
        merge_file('krumplumpl', 'test/data')
      end.create_container
    end
  end

  def test_missing_dir
    assert_raise IronCore::Error, "should check if merged dir exists" do
      code_bundle do
        merge_dir('dir2', 'test/data')
      end.create_container
    end
  end

  def test_merge_dir
    code = code_bundle do
      merge_dir('test/data/dir2', 'test/data')
      merge_exec('test/hello.rb')
    end

    inspect_zip(code) do |zip|
      assert zip.find_entry('test/data/dir2/test')
    end
  end

  def test_merge_dir_no_dest
    code = code_bundle do
      merge_dir('test')
      merge_exec('test/hello.rb')
    end

    inspect_zip(code) do |zip|
      assert zip.find_entry('test/hello.rb')
    end
  end

  def test_wrong_merges
    def check(msg, &block)
      assert_raise IronCore::Error, msg do
        code_bundle(&block).create_container
      end
    end

    check "should check if merged file is a regular file" do
      file 'test'
      exec 'test/hello.rb'
    end

    check "should check if merged dir is a dir" do
      dir 'Gemfile'
      exec 'test/hello.rb'
    end

    check("should check if merged exec is a file"){ exec 'test' }
  end

  def test_symlinks
    File.unlink 'test/data/dir1/dir2' if
      File.symlink? 'test/data/dir1/dir2'

    Dir.chdir('test/data/dir1') do
      File.symlink('../dir2', 'dir2')
    end

    code = code_bundle :name => 'test_symlinks' do
      merge_dir('test/data/dir1', 'test/data')
      merge_dir('test/data/dir2', 'test/data')
      worker_code 'puts File.read("test/data/dir1/dir2/test")'
    end

    inspect_zip(code) do |zip|
      assert_equal '../dir2', zip.read('test/data/dir1/dir2')
    end

    client.codes_create(code)
    task_id = client.tasks_create('test_symlinks').id
    client.tasks_wait_for(task_id)
    log = client.tasks_log(task_id)

    assert_equal "test\n", log

    File.unlink 'test/data/dir1/dir2'
  end

end
