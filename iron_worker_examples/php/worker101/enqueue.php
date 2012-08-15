<?php
require_once "phar://../iron_worker.phar";

$worker = new IronWorker();
$worker->debug_enabled = true;

$payload = array(
    'query' => "iron.io",
);
$task_id = $worker->postTask("PHPWorker101", $payload);

# Wait for task finish
$details = $worker->waitFor($task_id);
print_r($details);

$log = $worker->getLog($task_id);
echo "Task log:\n $log\n";