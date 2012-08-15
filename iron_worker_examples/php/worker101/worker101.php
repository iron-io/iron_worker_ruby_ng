<?php

require_once dirname(__FILE__) . "/lib/TwitterSearch.php";

echo("Starting PHP  Worker101\n");
$payload = getPayload();
echo("We got following params\n");
print_r($payload);
echo("\nSearching Twitter\n");
$query = $payload->query;
$search = new TwitterSearch($query);
$results = $search->results();
print_r($results);
$file = 'output.txt';
echo("Writing to file");
file_put_contents($file, $results[0]->text);
$from_file = file_get_contents($file);
echo("Text from file\n");
print_r($from_file);
echo("\nWorker101 completed.");
?>