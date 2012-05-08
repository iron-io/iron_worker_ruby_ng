require 'helpers'

class RubyMergesTest < IWNGTest

  def test_merge_file
    client.codes.create( code_bundle(:name => 'test_merge_file') do
                           merge_file 'test/hello.rb'
                           worker_code "require 'hello'"
                         end )

    id = client.tasks.create('test_merge_file').id

    client.tasks.wait_for(id)

    assert_equal "hello\n", client.tasks.log(id),
                 'correct output'
  end

  def test_merge_dir
    client.codes.create( code_bundle(:name => 'test_merge_dir') do
                           merge_dir 'test/data/dir2'
                           worker_code "puts File.read('dir2/test')"
                         end )

    id = client.tasks.create('test_merge_dir').id

    client.tasks.wait_for(id)

    assert_equal "test\n", client.tasks.log(id),
                 'correct output'
  end

end
