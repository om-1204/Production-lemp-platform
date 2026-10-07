<?php

require_once __DIR__ . '/../src/database.php';

header('Content-Type: application/json');

try {
    $db = getDatabaseConnection();

    $db->query('SELECT 1');

    http_response_code(200);

    echo json_encode([
        'status' => 'healthy',
        'database' => 'reachable'
    ]);

} catch (Throwable $e) {

    http_response_code(503);

    echo json_encode([
        'status' => 'unhealthy',
        'database' => 'unreachable'
    ]);
}
