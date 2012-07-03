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

    puts "--- cli output begin -------------------------------------"

    exec(cmd) if fork.nil?
    Process.wait

    puts File.read(out)

    puts "--- cli output end ---------------------------------------"

    assert $?.success?

    File.read(out)
  end

  def test_basic
    assert cli('codes.create', ruby_merge_exec: 'test/hello.rb') =~
      /Upload successful/

    assert cli('tasks.create', name: 'Hello') =~
      /Queued up.*"id":"(.{24})"/

    assert cli('tasks.log', '--wait', task_id: $1) =~
      /\nhello\n/

    assert cli('schedules.create', name: 'Hello') =~
      /Scheduled/
  end

  def test_argument
    assert cli('upload', 'test/workers/wfile_paths/wfile_paths.worker') =~
      /Upload successful/

    assert cli('upload', 'krumplumpl', ruby_merge_exec: 'test/hello.rb') =~
      /Upload successful/
  end

end
