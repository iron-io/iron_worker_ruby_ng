require_relative '../helpers'

class ExampleHelloTest < IWNGTest
  def test_basic
    Dir.chdir 'examples/hello_worker' do
      client.codes_create(code_bundle('hello'))

      log = `ruby -I../../../lib enqueue.rb`

      assert(log =~ /Starting RubyHelloWorker/, 'started')
      assert(log =~ /RubyHelloWorker completed/, 'completed')
    end
  end
end
