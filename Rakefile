require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'rake/testtask'
require 'tmpdir'
require 'jeweler'

Rake::TestTask.new do |t|
  examples_tests_dir = Dir.mktmpdir('iw_examples')

  Dir.glob('examples/**/**.rb').each do |path|
    next unless path =~ %r|/([^/]+)/\1.rb$|

    test_path = examples_tests_dir + '/test_example_' + $1 + '.rb' 

    File.open(test_path, 'w') do |out|
      out << "require 'helpers'\n"
      out << "class #{$1.capitalize}Test < Test::Unit::TestCase\n"
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
  t.test_files = FileList['test/**/**.rb', examples_tests_dir + '/**.rb']
  t.verbose = true
end

Jeweler::Tasks.new do |gem|
  gem.name = "iron_worker_ng"
  gem.homepage = "https://github.com/iron-io/iron_worker_ruby_ng"
  gem.description = %Q{New generation ruby client for IronWorker}
  gem.summary = %Q{New generation ruby client for IronWorker}
  gem.email = "info@iron.io"
  gem.authors = ["Andrew Kirilenko", "Iron.io, Inc"]
  gem.files.exclude('.document', 'Gemfile', 'Gemfile.lock', 'Rakefile', 'iron_worker_ng.gemspec')
end

Jeweler::RubygemsDotOrgTasks.new
