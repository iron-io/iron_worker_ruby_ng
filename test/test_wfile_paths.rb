require 'helpers'

class WfilePathsTest < IWNGTest

  def test_dir
    wf = 'test/workers/wfile_paths/wfile_paths.worker'
    code = IronWorkerNG::Code::Base.new(:workerfile => wf)

    client.codes.create code
    id = client.tasks.create('WfilePaths').id
    client.tasks.wait_for(id)

    assert_equal "hello\n", client.tasks.log(id)
  end

end
