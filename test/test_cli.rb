require 'helpers'

class CLITest < IWNGTest

  def cli(*args)
    if args.last.is_a? Hash
      args.pop.each do |k,v|
        args << "--" + k.to_s.gsub(/_/,'-') + " " + v.to_s
      end
    end

    args << '--debug'

    out = Tempfile.new('cli_output').path
    args << "2>&1 >#{out}"

    cmd = 'ruby -Ilib test/cli_runner.rb ' + args.join(' ')
    puts cmd

    exec(cmd) if fork.nil?
    Process.wait

    puts "--- cli output begin -------------------------------------"

    puts File.read(out)

    puts "--- cli output end ---------------------------------------"

    puts $?
    assert $?.success?

    File.read(out)
  end

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

end
