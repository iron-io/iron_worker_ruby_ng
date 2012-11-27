require_relative '../helpers'

class ExampleHelloTest < IWNGTest
  def test_basic
    Dir.chdir 'examples/ruby_ng/hello_worker' do
      client.codes_create(code_bundle('hello'))

      log = `ruby -I../../../lib enqueue.rb`

      assert(log =~ /Starting Ruby hello_worker/, 'started')
      assert(log =~ /hello_worker completed/, 'completed')
    end
  end
end
