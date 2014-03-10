require_relative 'helpers'

class CodeCreateTest < IWNGTest

  def test_create
    stacks_list = client.stacks_list
    assert stacks_list.is_a? Array
    assert stacks_list.count > 0
    assert stacks_list.include? 'python-2.7'
  end

  def test_wrong_stack
    code = code_bundle(:exec => 'test/hello.rb',:name => 'sample')
    code.stack('none')
      assert_raise Rest::Wrappers::RestClientExceptionWrapper do
      client.codes_create code
    end
  end

  def test_stacks
    client.stacks_list.each do |stack|
      client.codes.create(IronWorkerNG::Code::Base.new("test/stacks/#{stack}/#{stack}"))
      id = client.tasks.create(stack).id
      task = client.tasks.wait_for(id)
      assert_equal 'complete', task.status
    end
  end

end
