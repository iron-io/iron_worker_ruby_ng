require 'helpers'

class WorkerfileTest < IWNGTest

  def workerfile(str)
    Tempfile.open('workerfile_test', '.'){ |f| f << str }
  end

  def test_basic
    wf = workerfile <<EOF
runtime 'binary'
name 'ShHello'
exec 'test/hello.sh'
EOF

    code = IronWorkerNG::Code::Creator.create(:workerfile => wf.path)

    client.codes.create(code)

    id = client.tasks.create('ShHello').id

    client.tasks.wait_for(id)

    assert_equal "hello\n", client.tasks.log(id)
  end

end
