<?php
function trigger_alert(Exception $e, $api_key)
{
    $data = array(
        'service_key' => $api_key,
        "event_type" => "trigger",
        "description" => $e->__toString()
    );
    $ctx = stream_context_create(array(
        'method' => 'POST',
        'content' => json_encode($data)
    ));
    file_get_contents('https://events.pagerduty.com/generic/2010-04-15/create_event.json', null, $ctx);
}

$payload = getPayload();
try
{
    //your worker code here
}
catch (Exception $e)
{
    trigger_alert($e, $payload['API_KEY']);
}
