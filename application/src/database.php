<?php

function loadEnvironment(string $file): array
{
    if (!is_readable($file)) {
        throw new RuntimeException("Environment file is not readable.");
    }

    $config = [];

    foreach (file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        $line = trim($line);

        if ($line === '' || str_starts_with($line, '#')) {
            continue;
        }

        [$key, $value] = array_pad(explode('=', $line, 2), 2, '');

        $config[trim($key)] = trim($value);
    }

    return $config;
}

function getDatabaseConnection(): PDO
{
    $config = loadEnvironment('/etc/veriqta-portal/portal.env');

    $dsn = sprintf(
        'mysql:host=%s;dbname=%s;charset=utf8mb4',
        $config['DB_HOST'],
        $config['DB_NAME']
    );

    return new PDO(
        $dsn,
        $config['DB_USER'],
        $config['DB_PASSWORD'],
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );
}
