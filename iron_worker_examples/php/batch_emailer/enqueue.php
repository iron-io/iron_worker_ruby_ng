<?php
require_once "phar://../iron_worker.phar";

$worker = new IronWorker();

$payload = array(
    'address' => "",
    'name'    => "Dear Friend",
    'subject' => 'PHPMailer Test Subject via mail(), basic',
    'reply_to' => array(
        'address' => "name@example.com",
        'name'    => "First Last"
    ),
    'from'     =>  array(
        'address' => "me@example.com",
        'name'    => "First Last"
    ),
);

# Send 5 different mails
for ($i = 1; $i <= 5;$i++){
    $payload['address'] = "name_$i@example.com";
    $payload['name']    = "Dear Friend $i";

    $task_id = $worker->postTask("sendEmail-php", $payload);
    echo "task_id = $task_id \n";

    # Wait for task finish
    $details = $worker->waitFor($task_id);
    print_r($details);

    $log = $worker->getLog($task_id);
    echo "Task log:\n $log\n";
}