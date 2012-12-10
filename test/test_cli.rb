require_relative 'helpers'

class CLITest < IWNGTest

  def test_basic
    assert cli('upload', 'test/hello.worker') =~
      /Upload successful/

    assert cli('queue', 'hello') =~
      /Queued up.*"id":"(.{24})"/

    assert cli('log', '--wait', $1) =~
      /\nhello\n/

    assert cli('schedule', 'hello') =~
      /Scheduled/
  end

  def test_argument
    assert cli('upload', 'test/workers/wfile_paths/wfile_paths.worker') =~
      /Upload successful/

    tmp = File.open('krumplumpl.worker', 'w') { |f| f << 'exec "test/hello.rb"' }
    assert cli('upload', 'krumplumpl') =~
      /Upload successful/
    File.unlink tmp
  end

  def test_forced_name
    assert cli('upload', 'test/hello.worker', name: 'Frobnicator') =~
      /Upload successful.*Frobnicator/m
  end

end
