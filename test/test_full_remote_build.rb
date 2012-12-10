require_relative 'helpers'

class FullRemoteBuildTest < IWNGTest
  def test_basic
    client.codes_create code_bundle('test/workers/full_remote_build/pdftk')
    task_id = client.tasks.create('pdftk').id
    client.tasks.wait_for(task_id)
    assert client.tasks.log(task_id) =~ /pdftk 1\.44/
  end
end
