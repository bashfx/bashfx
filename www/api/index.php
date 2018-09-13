<?php 

define("HELLO_WORLD", "Hello there API.");
define("QUERY_STRING", $_SERVER['QUERY_STRING']);
define("USER_AGENT", $_SERVER['HTTP_USER_AGENT']);
define("REQ", $_REQUEST);
echo HELLO_WORLD;
?>

<pre>
<?
echo var_dump(USER_AGENT);
echo var_dump(QUERY_STRING);
echo var_dump(REQ);
?>
</pre>
