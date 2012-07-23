<?php
require_once "phar://../iron_worker.phar";

/*
 * This example demonstrates drawing images using GD library and uploading result to Amazon S3 storage
 */

$worker = new IronWorker();

$config = parse_ini_file('../config.ini', true);

$payload = array(
    's3' => array(
        'access_key' => $config['s3']['access_key'],
        'secret_key' => $config['s3']['secret_key'],
        'bucket'     => $config['s3']['bucket'],
    ),
    'image_url' => 'http://www.iron.io/assets/banner-mq-bg.jpg',
    'text'      => 'Hello from Iron Worker!'
);

# Adding new task.
$task_id = $worker->postTask("testGD_S3", $payload);

# Wait for task finish
$details = $worker->waitFor($task_id);
print_r($details);

$log = $worker->getLog($task_id);
echo "Task log:\n $log\n";