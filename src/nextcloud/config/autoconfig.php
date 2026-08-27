<?php

$snap_name = getenv('SNAP_NAME');

$data_path = getenv('SNAP_DATA_CURRENT');

$database_password = trim(file_get_contents($data_path . '/mysql/nextcloud_password'));

$AUTOCONFIG = array(
'directory' => getenv('NEXTCLOUD_DATA_DIR'),

'dbtype' => 'mysql',

'dbhost' => getenv('NEXTCLOUD_DB_HOST').':'.getenv('NEXTCLOUD_DB_PORT'),

'dbname' => 'nextcloud',

'dbuser' => 'nextcloud',

'dbpass' => $database_password,
);
