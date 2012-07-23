<?php
require_once "phar://../iron_worker.phar";

$worker = new IronWorker();

$task_id = $worker->postTask('HelloWorker', array(
    'some_param'  => 'some_value',
    'other_param' => array(1, 2, 3)
));

echo "Your task #$task_id has been queued up, check https://hud.iron.io to see your task status and log.";