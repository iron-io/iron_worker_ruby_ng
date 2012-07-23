<?php
$payload = getPayload();
$key = $payload['api_key'];
$i = $payload['i'];
$url = "http://logs.loggly.com/inputs/$key";
$ctx = stream_context_create(array(
    'method' => 'POST',
    'content' => "I am now logging to Loggly $i times."
));
file_get_contents($url, null, $ctx);
