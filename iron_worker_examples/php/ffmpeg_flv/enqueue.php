<?php
require_once "phar://../iron_worker.phar";

$worker = new IronWorker();
$worker->debug_enabled = true;

$payload = array(
    'input_file' => 'https://s3.amazonaws.com/iron-examples/video/iron_man_2_trailer_official.flv'
);
$task_id = $worker->postTask("FFmpeg-Flv", $payload);

# Wait for task finish
$details = $worker->waitFor($task_id);
print_r($details);

$log = $worker->getLog($task_id);
echo "Task log:\n $log\n";