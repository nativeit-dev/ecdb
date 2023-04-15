<?php

/* Ensure we got the environment */
$vars = [
    'ECDB_HOST',
    'ECDB_PORT',
    'ECDB_ABSOLUTE_URI',
    'MAX_EXECUTION_TIME',
    'MEMORY_LIMIT',
];

foreach ($vars as $var) {
    $env = getenv($var);
    if (!isset($_ENV[$var]) && $env !== false) {
        $_ENV[$var] = $env;
    }
}

/* Play nice behind reverse proxys */
if (isset($_ENV['ECDB_ABSOLUTE_URI'])) {
    $cfg['PmaAbsoluteUri'] = trim($_ENV['ECDB_ABSOLUTE_URI']);
}

/* Figure out hosts */

/* Fallback to default linked */
$hosts = ['localhost'];

/* Set by environment */
if (! empty($_ENV['ECDB_HOST'])) {
    $hosts = [$_ENV['ECDB_HOST']];
    $ports = [$_ENV['ECDB_PORT']];
}

/* Server settings */
for ($i = 1; isset($sockets[$i - 1]); $i++) {
    $cfg['Servers'][$i]['socket'] = $sockets[$i - 1];
    $cfg['Servers'][$i]['host'] = 'localhost';
}
/*
 * Revert back to last configured server to make
 * it easier in config.user.inc.php
 */
$i--;

/* PHP resources setup */

if (isset($_ENV['MAX_EXECUTION_TIME'])) {
    $cfg['ExecTimeLimit'] = $_ENV['MAX_EXECUTION_TIME'];
}

if (isset($_ENV['MEMORY_LIMIT'])) {
    $cfg['MemoryLimit'] = $_ENV['MEMORY_LIMIT'];
}
