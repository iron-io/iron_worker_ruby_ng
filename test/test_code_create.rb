require 'helpers'

class CodeCreateTest < IWNGTest

  def test_create
    code = code_bundle('test/hello.rb')
    assert_equal File.expand_path('test/hello.rb'), code.exec_path
    assert_equal 'Hello', code.name

    code = code_bundle(:name => 'asdfasdf')
    assert_equal nil, code.exec_path
    assert_equal 'asdfasdf', code.name

    code = code_bundle(:exec => 'test/hello.rb', :name => 'dfdfd')
    assert_equal File.expand_path('test/hello.rb'), code.exec_path
    assert_equal 'dfdfd', code.name

    code = code_bundle
    assert_equal nil, code.exec_path
    assert_equal nil, code.name
  end

  def test_workerfile
    Dir.chdir( Dir.mktmpdir ) do
      File.open('hello.rb', 'w') { |f| f << "puts 'hello'" }
      File.open('Workerfile', 'w') { |f| f << "exec 'hello.rb'" }

      assert code_bundle.exec_path.end_with? 'hello.rb'
    end
  end

  def test_upload
    resp = client.codes_create code_bundle('test/hello.rb')
    assert_equal 200, resp.status_code, "status ok"
    assert resp.id =~ /[0-9a-f]{24}/, "has id"
  end

end
