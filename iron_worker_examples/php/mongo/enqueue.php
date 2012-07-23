<?php
require_once "phar://../iron_worker.phar";

$worker = new IronWorker();

$config = parse_ini_file('../config.ini', true);

$task_id = $worker->postTask('Mongo', array(
    'db' => $config['mongo']
));

# Wait for task finish
$details = $worker->waitFor($task_id);
print_r($details);

# Check log
$log = $worker->getLog($task_id);
echo "Task log:\n $log\n";