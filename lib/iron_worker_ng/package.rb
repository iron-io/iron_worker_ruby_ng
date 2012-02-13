require 'tmpdir'
require 'zip/zip'

require_relative 'features'
require_relative 'features/common'

module IronWorkerNG
  class Package
    include IronWorkerNG::Features::Common::InstanceMethods

    attr_reader :name

    def create_zip
      zip_name = Dir.tmpdir + '/' + Dir::Tmpname.make_tmpname("iron-worker-ng-", "code.zip")
      
      Zip::ZipFile.open(zip_name, Zip::ZipFile::CREATE) do |zip|
        bundle(zip)
        create_runner(zip)
      end

      zip_name
    end

    def create_runner
    end

    def runtime
      nil
    end

    def runner
      nil
    end
  end
end
