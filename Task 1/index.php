<?php

require __DIR__ . '/Script.php';

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