require_relative '../helpers'

class ExampleSimpleTest < IWNGTest

  def test_example
    Dir.chdir 'examples/simple' do
      log = `ruby -I../../../lib simple.rb`

      assert(log =~ /default name is sample_worker/,
             'Default worker name is executable without extension')

      assert(log =~ /hash: name is transmogrify, exec is sample_worker\.rb/,
             'Constructor from hash works ok')

      assert(log =~ /block: name is transmogrify, exec is sample_worker\.rb/,
             'Constructor from block works ok')

      assert(log =~ /WARN -- IronWorkerNG: Ignoring attempt to merge exec/,
             'Warning about secondary exec')

      assert(log =~ /^exec is sample_worker\.rb$/,
             'Exec unchanged')

      assert(log =~ /code id is .*, message is Upload successful/,
             'Upload successful')

      assert(log =~ /\d+ codes created last hour/,
             'codes created')

      assert(log =~ /transmogrify code info (.*)$/,
             'transmogrify code info')
      info = $1
      assert_equal('transmogrify', eval(info)[:name], 'code name matches')

      assert(log =~ /another transmogrify code info (.*)$/,
             'another transmogrify code info')
      assert_equal info, $1

      assert(log =~ /task created:/, 'task created')
      assert(log =~ /task finished with status complete/, 'task finished')

      assert(log =~ /^hello$/, 'correct log')
    end
  end

end
