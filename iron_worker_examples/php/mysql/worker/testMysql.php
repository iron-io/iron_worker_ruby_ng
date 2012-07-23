<?php

$config =  parse_ini_file(dirname(__FILE__).'/config.ini', true);

mysql_connect($config['mysql']['server'].":".$config['mysql']['port'],
              $config['mysql']['username'],  $config['mysql']['password']);
mysql_selectdb($config['mysql']['db']);
mysql_query("SET names utf8");


# Do some hard work here
$query = 'SHOW TABLES;';
$result = mysql_query($query);
while($row = mysql_fetch_array($result)) {
    echo $row[0]."\n";
}

