require_relative 'helpers'

class LocalRunTest < IWNGTest
	CONFIG_FILE = File.dirname(__FILE__) + "/local_run_with_config.json" 
	WORKER_FILE = File.dirname(__FILE__) + "/local_run_with_config.worker"
	def test_with_worker_config_file
		test = /#{config_file_contents}/
		assert cli('run', "#{WORKER_FILE} --worker-config #{CONFIG_FILE}") =~	test
	end
	def test_with_no_config
		test = /#{nil.to_json}/
		assert cli('run', "#{WORKER_FILE}") =~ test
	end
	private
	def config_file_contents
		File.read(CONFIG_FILE)
	end
end