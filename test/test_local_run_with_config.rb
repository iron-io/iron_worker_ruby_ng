require_relative 'helpers'

class LocalRunTest < IWNGTest
	CONFIG_FILE = "local_run_with_config.json" 
	WORKER_FILE = "local_run_with_config.worker"
	def test_with_inline_config
		config = {local_run_config: "is present"}.to_json
		test = /#{config}/
		assert cli('run', "#{WORKER_FILE} --config '#{config}'") =~	test
	end
	def test_with_worker_config_file
		test = /#{config_file_contents}/
		assert cli('run', "#{WORKER_FILE} --worker-config #{CONFIG_FILE}") =~	test
	end
	def test_with_both_worker_config_file_and_inline_config_file_should_take_precedence
		inline_config = {inline_config: "should_not_be_present"}.to_json
		inline_test = /^((?!#{inline_config}).)*$/s
		file_test = /#{config_file_contents}/
		cli_output = cli('run', "#{WORKER_FILE} --worker-config #{CONFIG_FILE} --config '#{inline_config}'")
		assert cli_output =~ inline_test
		assert cli_output =~ file_test
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