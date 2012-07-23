<?php
include("../IronCore.class.php");
include("../IronWorker.class.php");
include("../IronMQ.class.php");
$name = "MasterSlaveMailer-php";

$iw = new IronWorker('config.ini');

//parsing config to get token and project_id
$data = @parse_ini_file('config.ini', true);

//uploading worker
$iw->upload(dirname(__FILE__)."/workers/master_email_worker", 'MasterEmailWorker.php', $name);



$payload = array(
    'host' => 'smtp.gmail.com',
    'port'    => 587,
    'username' => 'username',
    'password' => 'pass',
    'from'     => 'from@mail.com',
    'token'   => $data['iron_worker']['token'],
    'project_id'   => $data['iron_worker']['project_id']
);

$ironmq = new IronMQ(array(
    'token' => $data['iron_worker']['token'],
    'project_id' => $data['iron_worker']['project_id']
));

//filing queue with emails
for ($i = 0; $i < 20;$i++) {
    $ironmq->postMessage('mail',$i.'sample@email.com');
}

$task_id = $iw->postTask($name, $payload);
echo "task_id = $task_id \n";

// Wait for task finish
$details = $iw->waitFor($task_id);
print_r($details);

$log = $iw->getLog($task_id);
echo "Task log:\n $log\n";


