require 'net/http'
require 'net/https'
require 'tmpdir'

module IronWorkerNG
  class Fetcher
    def self.fetch(url, to_file = false)
      if url.start_with?('http://') || url.start_with?('https://')
        uri = URI.parse(url)

        http = Net::HTTP.new(uri.host, uri.port)

        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        response = http.request(Net::HTTP::Get.new(uri.request_uri))

        if response.kind_of?(Net::HTTPRedirection)
          return IronWorkerNG::Fetcher.fetch(response['location'], to_file)
        end

        if to_file
          tmp_dir_name = Dir.tmpdir + '/' + Dir::Tmpname.make_tmpname("iron-worker-ng-", "http")

          Dir.mkdir(tmp_dir_name)
 
          File.open(tmp_dir_name + '/' + File.basename(url), 'wb') do |f|
            f.write(response.body)
          end

          [tmp_dir_name + '/' + File.basename(url), tmp_dir_name]
        else
          [response.body, nil]
        end
      else
        unless File.exists?(url)
          return [nil, nil]
        end

        if to_file
          [url, nil]
        else
          [File.read(url), nil]
        end
      end
    end
  end
end
