require "rubygems"
require "json"
require "zip/zip"
require "s3"
require "open-uri"

def create_gem(bucket, gem, version)
  begin
    puts "installing clean copy #{gem} #{version}"

    system("mkdir gem")
    system("gem uninstall #{gem} -q -I -x")
    res = system("cd gem && gem install #{gem} -v #{version} --no-ri --no-rdoc --ignore-dependencies -i __gems__")

    if not res
      puts "installation failed"
      raise
    end

    puts "packing"

    system("rm -rf gem/__gems__/build_info gem/__gems__/cache gem/__gems__/doc")

    Zip.options[:continue_on_exists_proc] = true

    Zip::File.open("#{gem}-#{version}.zip", Zip::ZipFile::CREATE) do |zip|
      Dir["gem/**/**"].each do |f|
        zip.add(f[4 .. -1], f)
      end
    end

    puts "creating deps file"

    deps = [Gem::Dependency.new(gem, version)]
    spec = Gem::Resolver.new(deps).resolve.first.spec
    dependencies = spec.dependencies.reject { |dep| dep.type != :runtime }.map { |dep| {gem: dep.name, version: dep.requirement.to_s} }.to_json

    File.open("#{gem}-#{version}.deps", "w") do |deps|
      deps.puts dependencies.to_json
    end

    puts "uploading to S3"

    zip = bucket.objects.build("#{gem}-#{version}.zip")
    zip.content = open("#{gem}-#{version}.zip")
    zip.save

    deps = bucket.objects.build("#{gem}-#{version}.deps")
    deps.content = open("#{gem}-#{version}.deps")
    deps.save
  rescue
  ensure
    system("rm -rf gem")
    system("rm #{gem}-#{version}.zip")
    system("rm #{gem}-#{version}.deps")
  end
end

stack = ARGV.length == 1 ? "-" + ARGV[0] : ""

puts "Stack:#{stack}"

config = JSON.parse(File.read("gb.json"))

s3_access_key_id = config["s3_access_key_id"]
s3_secret_access_key = config["s3_secret_access_key"]

s3 = S3::Service.new(access_key_id: s3_access_key_id, secret_access_key: s3_secret_access_key)
bucket = s3.buckets.find("iron_worker_ng_gems#{stack}")

gems_data = open("https://raw.githubusercontent.com/iron-io/iron_worker_ruby_ng/master/tools/gems.json") { |f| f.read }
gems = JSON.parse(gems_data)["gems"]

gems.each do |gem|
  begin
    deps = [Gem::Dependency.new(gem[0], gem[1])]
    spec = Gem::Resolver.new(deps).resolve.first

    versions = spec.instance_variable_get("@others_possible").map { |o| o.version.to_s }
    versions << spec.spec.version.to_s

    versions.each do |version|
      begin
        bucket.objects.find("#{gem[0]}-#{version}.zip")
        bucket.objects.find("#{gem[0]}-#{version}.deps")
      rescue
        create_gem(bucket, gem[0], version)
      end
    end
  rescue
    puts "Unexpected error while building #{gem[0]} #{gem[1]}"
  end
end
