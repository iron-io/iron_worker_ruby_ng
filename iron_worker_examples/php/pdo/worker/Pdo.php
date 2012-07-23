<?php

$payload = getPayload();

$connect_str = "{$payload->connection->driver}:host={$payload->connection->driver};dbname={$payload->connection->db}";
$db = new PDO($connect_str, $payload->connection->user, $payload->connection->password);


# Some hard work with db here.
$rows = $db->exec("SELECT NOW() AS `now`;");
print_r($rows);
