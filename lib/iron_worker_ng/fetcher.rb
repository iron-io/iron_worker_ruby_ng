require 'net/http'
require 'net/https'
require 'tmpdir'
require 'fileutils'

module IronWorkerNG
  class Fetcher
    def self.remote?(url)
      url.start_with?('http://') || url.start_with?('https://')
    end

    def self.fix_github_url(url)
      if url.start_with?('http://github.com/') || url.start_with?('https://github.com/')
        fixed_url = url.sub('//github.com/', '//raw.github.com/').sub('/blob/', '/')

        IronCore::Logger.info 'IronWorkerNG', "Fixed github link with url='#{url}' to url='#{fixed_url}'"

        return fixed_url
      end

      url
    end

    def self.fetch(url, &block)
      if IronWorkerNG::Fetcher.remote?(url)
        url = IronWorkerNG::Fetcher.fix_github_url(url)

        uri = URI.parse(url)

        http = Net::HTTP.new(uri.host, uri.port)

        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        response = http.request(Net::HTTP::Get.new(uri.request_uri))

        if response.kind_of?(Net::HTTPRedirection)
          IronWorkerNG::Fetcher.fetch(response['location'], &block)

          return
        end

        block.call(response.body) unless block.nil?
      else
        unless File.exists?(url)
          block.call(nil) unless block.nil?

          return
        end

        block.call(File.read(url)) unless block.nil?
      end
    end

    def self.fetch_to_file(url, &block)
      if IronWorkerNG::Fetcher.remote?(url)
        IronWorkerNG::Fetcher.fetch(url) do |data|
          unless data.nil?
            tmp_dir_name = ::Dir.tmpdir + '/' + ::Dir::Tmpname.make_tmpname('iron-worker-ng-', 'http')

            ::Dir.mkdir(tmp_dir_name)

            File.open(tmp_dir_name + '/' + File.basename(url), 'wb') do |f|
              f.write(data)
            end

            block.call(tmp_dir_name + '/' + File.basename(url)) unless block.nil?

            FileUtils.rm_rf(tmp_dir_name)
          end
        end
      else
        unless File.exists?(url)
          block.call(nil) unless block.nil?

          return
        end

        block.call(url) unless block.nil?
      end
    end
  end
end
