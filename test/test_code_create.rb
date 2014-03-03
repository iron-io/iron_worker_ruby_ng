require_relative 'helpers'

class CodeCreateTest < IWNGTest

  def test_create
    code = code_bundle(:name => 'asdfasdf')
    assert_equal nil, code.exec
    assert_equal 'asdfasdf', code.name

    code = code_bundle(:exec => 'test/hello.rb', :name => 'dfdfd')
    assert_equal 'test/hello.rb', code.exec.path
    assert_equal 'dfdfd', code.name

    code = code_bundle
    assert_equal nil, code.exec
    assert_equal nil, code.name
  end

  def test_big_file_upload
    system "dd if=/dev/urandom of=test/big_file.txt count=10240 bs=1024"
    code = code_bundle(:exec => 'test/big_file.txt', :name => 'big_file')
    resp = client.codes_create code
    assert_equal "Upload successful.", resp.msg
    assert resp.id =~ /[0-9a-f]{24}/, "has id"
  end

  def test_name
    resp = client.codes_create code_bundle('test/hello.worker')
    assert_equal "Upload successful.", resp.msg
    assert resp.id =~ /[0-9a-f]{24}/, "has id"
  end

  def test_block_init
    i = 0
    IronWorkerNG::Code::Base.new do
      exec 'test/hello.rb'
      i += 1
    end
    assert_equal 1, i,
                 "block should be executed once"
  end

  def test_invalid
    assert_raise do
      code_bundle(asdf: 1)
    end
  end

end
