<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

require 'vendor/predis/predis/autoload.php';

Predis\Autoloader::register();

if (isset($_GET['cmd']) === true) {
  $host = 'redis-master';
  if (getenv('GET_HOSTS_FROM') == 'env') {
    $host = getenv('REDIS_LEADER_SERVICE_HOST');
    $port = getenv('REDIS_LEADER_SERVICE_PORT');
  }
  header('Content-Type: application/json');
  if ($_GET['cmd'] == 'set') {
    $client = new Predis\Client([
      'scheme' => 'tcp',
      'host'   => $host,
      'port'   => $port,
      'password'   => getenv('REDIS_PASSWORD'),
    ]);

    $client->set($_GET['key'], $_GET['value']);
    print('{"message": "Updated"}');
  } else {
    $host = 'redis-replica';
    if (getenv('GET_HOSTS_FROM') == 'env') {
      $host = getenv('REDIS_LEADER_SERVICE_HOST');
      $port = getenv('REDIS_LEADER_SERVICE_PORT');
    }
    $client = new Predis\Client([
      'scheme' => 'tcp',
      'host'   => $host,
      'port'   => $port,
      'password'   => getenv('REDIS_PASSWORD'),
    ]);

    $value = $client->get($_GET['key']);
    $sanitized_value = htmlspecialchars($value ?? '', ENT_QUOTES, 'UTF-8');
    print('{"data": "' . $sanitized_value . '"}');
  }
} else {
  phpinfo();
} ?>
