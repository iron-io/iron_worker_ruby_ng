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

process.argv.forEach(function(val, index, array) {
  if (val == "-payload" && index < process.argv.length) {
    params = JSON.parse(fs.readFileSync(process.argv[index + 1], 'ascii'));
  }

  if (val == "-id" && index < process.argv.length) {
    task_id = process.argv[index + 1];
  }
});

exports.params = params;
exports.task_id = task_id;

NODE_RUNNER
          end
        end

        def runtime_run_code(local = false)
          <<RUN_CODE
node #{File.basename(@exec.path)} "$@"
RUN_CODE
        end
      end
    end
  end
end
