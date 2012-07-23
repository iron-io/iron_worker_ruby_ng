<?php
include("./lib/IronCore.class.php");
include("./lib/IronWorker.class.php");
include("./lib/IronMQ.class.php");

function queue_worker($payload,$emails)
{
    $name = "emailWorker.php";
    $iw = new IronWorker(array(
                         'token' => $payload->token,
                         'project_id' => $payload->project_id
                         ));

    $payload = array(
        'host' => $payload->host,
        'port'    => $payload->port,
        'username' => $payload->username,
        'password' => $payload->username,
        'from'     => $payload->from,
        'to'     => $emails,
        'subject' => "Welcome emails",
        'body'    => "Hey it's a body",
        'token' => $payload->token,
        'project_id' => $payload->project_id
    );

    $task_id = $iw->postTask($name, $payload);
    echo "task_id = $task_id \n";
    # Wait for task finish
    $details = $iw->waitFor($task_id);
    print_r($details);
    $log = $iw->getLog($task_id);
    echo "Task log:\n $log\n";
}

function get_emails($token,$project_id)
{
//initializing iron_mq
    $ironmq = new IronMQ(array(
        'token' => $token,
        'project_id' => $project_id
    ));
//getting 100 messages from iron_mq
    $messages = $ironmq->getMessages('mail',100);
    $emails = array();
    foreach($messages as $message)
    {
    //adding message body to list of emails
      $emails[] = $message->body;
    //deleting message from queue
      $ironmq->deleteMessage('mail', $message->id);
    }
    return $emails;
}


$payload = getPayload();

//getting list of emails to send from iron_mq
$emails = get_emails($payload->token,$payload->project_id);

echo "List of emails";
print_r($emails);

if (!empty($emails)) {
    //split array into small arrays with max 10 elems per each
    $chunked_list = array_chunk($emails,10);

    foreach($chunked_list as $email)
    {
    //queueing worker for each array
        queue_worker($payload,$emails);
    }
}

echo "Worker is done";