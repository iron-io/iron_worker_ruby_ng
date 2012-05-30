require 'helpers'

class WorkerfileTest < IWNGTest

  def workerfile(str)
    dir = Dir.mktmpdir('workerfile_test')
    File.open(dir + '/Workerfile', 'w'){ |f| f << str }.path
  end

  def test_basic
    wf = workerfile <<EOF
runtime 'binary'
name 'ShHello'
exec 'test/hello.sh'
EOF

    code = IronWorkerNG::Code::Creator.create(:workerfile => wf)

    client.codes.create(code)

    id = client.tasks.create('ShHello').id

    client.tasks.wait_for(id)

    assert_equal "hello\n", client.tasks.log(id)
  end

end
