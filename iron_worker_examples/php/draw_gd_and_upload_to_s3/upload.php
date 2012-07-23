<?php
require_once "phar://../iron_worker.phar";

$worker = new IronWorker();

# Creating and uploading code package.
$worker->upload("worker/", 'gd_s3.php', "testGD_S3");