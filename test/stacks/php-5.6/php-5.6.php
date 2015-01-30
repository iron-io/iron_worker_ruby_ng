<?php
    $php_version = explode('.', PHP_VERSION);
    if ($php_version[0]!=5 || $php_version[1]!=6) {
        throw new Exception("Wrong php version");
    }

    $hhvm_version = explode('.', HHVM_VERSION);
    if ($hhvm_version[0]!=3 || $hhvm_version[1]!=5) {
        throw new Exception("Wrong php version");
    }
    print_r($php_version);
    print_r($hhvm_version);
?>