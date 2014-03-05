module IronWorkerNG
  module Code
    module Runtime
      module PHP
        include IronWorkerNG::Feature::Common::MergeExec::InstanceMethods

        def runtime_bundle(container, local = false)
          container.get_output_stream(@dest_dir + '__runner__.php') do |runner|
            runner.write <<PHP_RUNNER
<?php
/* #{IronWorkerNG.full_version} */

function getArgs() {
  global $argv;

  $args = array('task_id' => null, 'dir' => null, 'payload' => array(), 'config' => null);

  foreach ($argv as $k => $v) {
    if (empty($argv[$k + 1])) continue;

    if ($v == '-id') $args['task_id'] = $argv[$k + 1];
    if ($v == '-d')  $args['dir']     = $argv[$k + 1];

    if ($v == '-payload' && file_exists($argv[$k + 1])) {
      $args['payload'] = file_get_contents($argv[$k + 1]);

      $parsed_payload = json_decode($args['payload']);

      if ($parsed_payload != null) {
        $args['payload'] = $parsed_payload;
      }
    }

    if ($v == '-config' && file_exists($argv[$k + 1])) {
      $args['config'] = file_get_contents($argv[$k + 1]);

      $parsed_config = json_decode($args['config'], true);

      if ($parsed_config != null) {
          $args['config'] = $parsed_config;
      }
    }
  }

  return $args;
}

function getPayload() {
  $args = getArgs();

  return $args['payload'];
}

function getConfig(){
  $args = getArgs();

  return $args['config'];
}

require '#{File.basename(@exec.path)}';
PHP_RUNNER
          end
        end

        def runtime_run_code(local, params)
          <<RUN_CODE
TERM=dumb php __runner__.php #{params}
RUN_CODE
        end
      end
    end
  end
end
