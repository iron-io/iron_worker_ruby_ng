<?php
require_once "phar://../iron_worker.phar";

$worker = new IronWorker();
$worker->debug_enabled = true;

$payload = array(
    'key_one' => 'Payload',
    'key_two' => 2
);

# 3 minutes later
$start_at = time()+3*60;

# Run task every 2 minutes 10 times
$schedule_id = $worker->postScheduleAdvanced("Scheduling", $payload, $start_at, 2*60, null, 10);

# Get schedule information
$schedule = $worker->getSchedule($schedule_id);
print_r($schedule);

