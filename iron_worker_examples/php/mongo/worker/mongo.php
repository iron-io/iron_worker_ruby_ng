<?php

# Load config data from payload
$payload = getPayload();
$cfg = $payload->db;
$connection_string = "mongodb://{$cfg->username}:{$cfg->password}@{$cfg->host}:{$cfg->port}/{$cfg->db}";
echo "connection_string: $connection_string\n";

# Connect
$mongo = new Mongo($connection_string);
$db = $mongo->selectDB($cfg->db);

# Pick a collection
$collection = $db->items;

# Insert item to collection
$item = array( "title" => "Title", "text" => "Hello, php" );
$collection->insert($item);

# Get item from collection
$cursor = $collection->find();
foreach($cursor as $item){
	var_dump($item);
}