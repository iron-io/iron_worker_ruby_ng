require 'tmpdir'
require 'zip/zip'

require 'iron_worker_ng/mergers'

module IronWorkerNG
  class Code
    include IronWorkerNG::Mergers::InstanceMethods

    attr_reader :merges
    attr_reader :merged_gems
    attr_reader :main_worker

    def create_zip
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
$:.unshift("\#{root}")

require '#{File.basename(@main_worker.path).sub(/\.rb$/, '')}'

worker = #{@main_worker.name}.new
worker.run
RUNNER
        end
      end

      zip_name
    end
  end
end
