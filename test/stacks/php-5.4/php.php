<?php
$fixed_ext = array('Core','date','ereg','libxml','openssl','pcre','zlib','bcmath','bz2','calendar','ctype','dba','dom','hash','fileinfo','filter','ftp','gettext','SPL','iconv','mbstring','pcntl','session','posix','Reflection','standard','shmop','SimpleXML','soap','sockets','Phar','exif','sysvmsg','sysvsem','sysvshm','tokenizer','wddx','xml','xmlreader','xmlwriter','zip','PDO','curl','gd','json','mysql','mysqli','pdo_mysql','pdo_pgsql','imagick','pgsql','readline','xsl','mongo','mcrypt','mhash','Zend OPcache');
$extensions = get_loaded_extensions();
foreach ($extensions as $extension) {
    if (!in_array($extension, $fixed_ext)) {
        throw new Exception("Extension not found: $extension \n");
    }
}
$version = explode('.', PHP_VERSION);
if ($version[0]!=5 || $version[1]!=4) {
    throw new Exception("Wrong php version");
}
?>