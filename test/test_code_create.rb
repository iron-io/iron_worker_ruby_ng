require 'helpers'

class CodeCreateTest < IWNGTest

  def test_wrong_args
    assert_raises RuntimeError do
      code_bundle('Hello', 'hello.rb')
    end

    assert_raises RuntimeError do
      code_bundle('hello.rb', :name => 'Hello')
    end

    assert_raises RuntimeError do
      client.codes_create(code_bundle(:worker_path => 'hello.rb',
                                      :name => 'Hello'))
    end
  end

  def test_create
    code = code_bundle('test/hello.rb')
    assert_equal File.expand_path('test/hello.rb'), code.exec_path
    assert_equal 'Hello', code.name

    code = code_bundle('asdfasdf')
    assert_equal nil, code.exec_path
    assert_equal 'asdfasdf', code.name

    code = code_bundle(:exec => 'test/hello.rb', :name => 'dfdfd')
    assert_equal File.expand_path('test/hello.rb'), code.exec_path
    assert_equal 'dfdfd', code.name
  end

end
