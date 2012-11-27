require_relative '../helpers'

class ExampleMasterSlaveTest < IWNGTest
  def test_basic
    Dir.chdir 'examples/ruby_ng/master_slave' do
      client.codes_create(code_bundle('master'))
      client.codes_create(code_bundle('slave'))

      log = `ruby -I../../../lib enqueue.rb`

      assert(log =~ /task id =/, 'task created')
      assert(log =~ /Queueing slave one with params \{"foo"=>"bar"\}/,
             'first slave enqueued')
      assert(log =~ /Queueing slave two with params \{"hello"=>"world"\}/,
             'second slave enqueued')
      assert(log =~ /Done/, 'done')
    end
  end
end
