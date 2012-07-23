<?php
require_once "phar://../iron_worker.phar";

$worker = new IronWorker();
$worker->debug_enabled = true;

$payload = array('api_key' => AIRBRAKE_API_KEY);

$worker->postTask("AirBrake", $payload);

