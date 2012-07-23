<?php
require_once "phar://../iron_worker.phar";

$worker = new IronWorker();
$worker->debug_enabled = true;

$payload = array(
    'API_KEY' => PAGERDUTY_API_KEY
);

$worker->postTask("PagerDuty", $payload);

