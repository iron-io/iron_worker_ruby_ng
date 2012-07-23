<?php
require_once "phar://../iron_worker.phar";

$worker = new IronWorker();

$worker->upload("worker/", 'Pdo.php', "PDO");