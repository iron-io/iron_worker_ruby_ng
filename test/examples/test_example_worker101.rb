require_relative '../helpers'

class ExampleWorker101Test < IWNGTest
  def test_example
    Dir.chdir 'examples/worker101' do
      assert cli('upload', 'worker101') =~ /Upload successful/
      log = `ruby enqueue.rb`
      assert log =~ /Worker101 completed/
    end
  end
end
