<?php

include("phar://".dirname(__FILE__)."/zend/zf_1_11_0.phar.gz");

// Set current locale
$locale = new Zend_Locale('en_US');
Zend_Registry::set('Zend_Locale', $locale);

// Create Currency object
$currency = new Zend_Currency(
    array(
      'value'  => 10000
    )
);

echo "\nCurrency is: $currency\n";


