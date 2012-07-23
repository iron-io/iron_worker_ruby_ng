<?php
$payload = getPayload();
require_once dirname(__FILE__) . '/lib/Airbrake.class.php';
$brake = new Services_Airbrake($payload->api_key, 'production', 'curl');

// YOUR WORKER CODE HERE

try {
    //do something
}
catch (Exception $e) {
    $brake->notify(get_class($e), $e->getMessage(), $e->getFile(), $e->getLine(), $e->getTrace(), "worker");
}
