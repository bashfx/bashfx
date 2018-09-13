<?php 
define("HELLO_WORLD", "Hello there Get hook.");
echo HELLO_WORLD;

$headers = apache_request_headers();

foreach ($headers as $header => $value) {
    echo "$header: $value <br />\n";
}


?>