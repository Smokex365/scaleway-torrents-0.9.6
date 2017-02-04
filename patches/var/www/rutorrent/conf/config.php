<?php
/*
  Override the base configuration of ruTorrent.
*/

include('/var/www/rutorrent/conf/config_base.php');

$topDirectory = '/home/rtorrent/';

$pathToExternals = array(
  "php"  => '/usr/bin/php',
  "curl" => '/usr/bin/curl',
  "gzip" => '/bin/gzip',
  "id"   => '/usr/bin/id',
  "stat" => '/usr/bin/stat',
);

$scgi_port = 5000;
$scgi_host = '127.0.0.1';
