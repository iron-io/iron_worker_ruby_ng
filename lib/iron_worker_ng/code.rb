require 'tmpdir'
require 'zip/zip'

require 'iron_worker_ng/mergers'

module IronWorkerNG
  class Code
    include IronWorkerNG::Mergers::InstanceMethods

    def create_zip(worker_file, worker_class)
      merge_file worker_file

      zip_name = Dir.tmpdir + '/' + Dir::Tmpname.make_tmpname("iron-worker-ng", "zip")
      
      Zip::ZipFile.open(zip_name, Zip::ZipFile::CREATE) do |zip|
        init_code = execute_merge(zip)

        zip.get_output_stream('runner.rb') do |runner|
          runner.write <<RUNNER
# IronWorgerNG #{File.read(File.dirname(__FILE__) + '/../../VERSION').gsub("\n", '')}

require 'optparse'

root = '.'
OptionParser.new do |opts|
  opts.on('-d', '--directory [DIRECTORY]') { |v| root = v }
end.parse!

#{init_code}
$: << "\#{root}"

require '#{worker_file.sub(/\.rb$/, '')}'

worker = #{worker_class}.new
worker.run
RUNNER
        end
      end

      zip_name
    end
  end
end
