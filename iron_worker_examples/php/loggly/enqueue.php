<?php
require_once "phar://../iron_worker.phar";

$worker = new IronWorker();
$worker->debug_enabled = true;

# launch 50 workers
for ($i = 1; $i <= 50; $i++) {
    $payload = array('api_key' => LOGGLY_KEY, 'i' => $i);

    $worker->postTask('Loggly', $payload);
}