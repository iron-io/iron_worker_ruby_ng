<?php
require_once "phar://../iron_worker.phar";

$worker = new IronWorker();
$worker->debug_enabled = true;

$config = parse_ini_file('../config.ini', true);

$payload = array(
    'connection'        => $config['pdo'],
    'yet_another_value' => array('value', 'value #2')
);

$task_id = $worker->postTask("PDO", $payload);

# Wait for task finish
$details = $worker->waitFor($task_id);
print_r($details);

$log = $worker->getLog($task_id);
echo "Task log:\n $log\n";