require 'tmpdir'
require 'zip/zip'

require 'iron_worker_ng/mergers'

module IronWorkerNG
  class Code
    include IronWorkerNG::Mergers::InstanceMethods

    def create_zip(worker_file, worker_class)
      merge_file worker_file

      zip_name = Dir.tmpdir + '/' + Dir::Tmpname.make_tmpname("iron-worker-ng-", "code.zip")
      
      Zip::ZipFile.open(zip_name, Zip::ZipFile::CREATE) do |zip|
        init_code = execute_merge(zip)

        zip.get_output_stream('runner.rb') do |runner|
          runner.write <<RUNNER
# IronWorker NG #{File.read(File.dirname(__FILE__) + '/../../VERSION').gsub("\n", '')}

root = '.'

0.upto($*.size - 2) do |i|
  root = $*[i + 1] if $*[i] == '-d'
end

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
