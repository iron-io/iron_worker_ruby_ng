require 'yaml'

module ExamplesHelper

  # Will load config from various locations, either in your Dropbox folder so it's synced or the _config.yml
  # file in this directory.
  def self.load_config
    # check for config
    # First check if running in abt worker
    if defined? $abt_config
      @config = $abt_config
      return @config
    end
    cf = File.expand_path(File.join("~", "Dropbox", "configs", "iron_worker_examples", "config.yml"))
    if File.exist?(cf)
      @config = YAML::load_file(cf)
      return @config
    end
    @config = YAML.load_file(File.join(File.dirname(__FILE__), '_config.yml'))
  end
end
