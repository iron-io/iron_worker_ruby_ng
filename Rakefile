require 'rubygems'

require 'rake/testtask'
require 'tmpdir'

Rake::TestTask.new do |t|
  examples_tests_dir = Dir.mktmpdir('iw_examples')

  FileUtils::cp_r(Dir.glob('examples/*'), examples_tests_dir)

  Dir.glob('examples/**/**.rb').each do |path|
    next unless path =~ %r|examples/(.*)/([^/]+)/\2.rb$|

    dir = $1
    name = $2

    test_path = examples_tests_dir + "/#{dir}/#{name}/test_#{name}.rb"

    File.open(test_path, 'w') do |out|
      out << "require 'helpers'\n"
      out << "class #{name.capitalize}Test < Test::Unit::TestCase\n"
      out << "def test_example\n"

      File.readlines(path).each do |line|
        line, assert_str = line.chomp.split /#>/
        out << line << "\n"

        if assert_str
          cond, desc = assert_str.split /--/
          out << "assert(" << cond << ", '" <<
            (desc or "").gsub(/'/, "\\\\'") << "')\n"
        end
      end

      out << "end\nend\n"
    end
  end

  t.libs << "lib" << "test" << examples_tests_dir
  t.test_files = FileList['test/**/**.rb',
                          examples_tests_dir + '/**/test_*.rb']
  t.verbose = true
end

require 'bundler'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  begin
    Bundler.setup(:default, :development)
  rescue Bundler::BundlerError => e
    $stderr.puts e.message
    $stderr.puts "Run `bundle install` to install missing gems"
    exit e.status_code
  end

  gem.name = "iron_worker_ng"
  gem.homepage = "https://github.com/iron-io/iron_worker_ruby_ng"
  gem.description = %Q{New generation ruby client for IronWorker}
  gem.summary = %Q{New generation ruby client for IronWorker}
  gem.email = "info@iron.io"
  gem.authors = ["Andrew Kirilenko", "Iron.io, Inc"]
  gem.files.exclude('.document', 'Gemfile', 'Gemfile.lock', 'Rakefile', 'iron_worker_ng.gemspec')
end

Jeweler::RubygemsDotOrgTasks.new
