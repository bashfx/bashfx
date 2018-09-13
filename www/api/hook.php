<?php 

define("HELLO_WORLD", "Hello there API hook.");
define("QUERY_STRING", $_SERVER['QUERY_STRING']);
define("USER_AGENT", $_SERVER['HTTP_USER_AGENT']);
define("REQ", $_REQUEST);
define("METHOD", $_SERVER['REQUEST_METHOD']);

echo HELLO_WORLD;
?>

<pre>
<?
try {

  $out = shell_exec("git pull origin master > ~/php-debug.log 2>&1");

  if( METHOD != 'POST' ){
    echo var_dump(USER_AGENT);
    echo var_dump(QUERY_STRING);
    echo var_dump(REQ);

    if( $_REQUEST['event'] == "push" ){ 
      echo "PUSH IT!";
    }
  }

} catch (Exception $e) {
  echo 'Caught exception: ',  $e->getMessage(), "\n";
}

?>
</pre>
