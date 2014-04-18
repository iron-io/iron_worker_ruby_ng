module IronWorkerNG
  module Code
    module Runtime
      module Node
        include IronWorkerNG::Feature::Common::MergeExec::InstanceMethods

        def runtime_bundle(container, local = false)
          container.get_output_stream(@dest_dir + 'node_modules/node_helper.js') do |runner|
            runner.write <<NODE_RUNNER
/* #{IronWorkerNG.full_version} */

var fs = require('fs');
var params = null;
var task_id = null;
var config = null;
var env = null;

process.argv.forEach(function(val, index, array) {
  if (val == "-payload") {
    params = JSON.parse(fs.readFileSync(process.argv[index + 1], 'utf8'));
  }

  if (val == "-config") {
    config = JSON.parse(fs.readFileSync(process.argv[index + 1], 'utf8'));
  }
  
    if (val == "-e") {
    env = JSON.parse(fs.readFileSync(process.argv[index + 1], 'utf8'));
  }

  if (val == "-id") {
    task_id = process.argv[index + 1];
  }
});

exports.params = params;
exports.config = config;
exports.env = env;
exports.task_id = task_id;

NODE_RUNNER
          end
        end

        def runtime_run_code(local, params)
          <<RUN_CODE
node #{File.basename(@exec.path)} #{params}
RUN_CODE
        end
      end
    end
  end
end
