<?php

require __DIR__ . '/Script.php';

// Connection to Redis
putenv(Script::REDIS_HOST . "=Redis-7.0");
putenv(Script::REDIS_PORT . "=6379");

try {
    print 'Started' . "\n";
    $script = new Script();
    $script->run();
    print 'Done';
} catch (Exception $e) {
    print 'Failed: ' . $e->getMessage();
    if (isset($script)) {
        $script->closeConnection();
    }
}


?>