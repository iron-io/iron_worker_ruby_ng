<?php
include("../IronCore.class.php");
include("../IronWorker.class.php");

$name = "emailWorker.php";

$iw = new IronWorker('config.ini');

//uploading worker
$iw->upload(dirname(__FILE__)."/workers/email_worker", 'emailWorker.php', $name);


$payload = array(
    'host' => 'smtp.gmail.com',
    'port'    => 587,
    'username' => 'username',
    'password' => 'passw',
    'from'     => 'from@mail.com',
    'to'     => 'sample@mail.com',
    'subject' => "Title",
    'body'    => "Hey it's a body"
);

//queueing task
$task_id = $iw->postTask($name, $payload);


