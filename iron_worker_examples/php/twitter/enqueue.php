<?php
require_once "phar://../iron_worker.phar";

$worker = new IronWorker();
$worker->debug_enabled = true;

$payload = array(
    'message' => "Hello From PHPWorker at ".date('r')."!\n",
    'url'     => 'http://www.iron.io/'
);
$task_id = $worker->postTask("Twitter", $payload);

# Wait for task finish
$details = $worker->waitFor($task_id);
print_r($details);

$log = $worker->getLog($task_id);
echo "Task log:\n $log\n";