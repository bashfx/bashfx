<?php 

define("HELLO_WORLD", "Hello there API hook.");
define("QUERY_STRING", $_SERVER['QUERY_STRING']);
define("USER_AGENT", $_SERVER['HTTP_USER_AGENT']);
define("REQ", $_REQUEST);
define("GETS", $_GET);
define("POSTS", $_POST);
define("METHOD", $_SERVER['REQUEST_METHOD']);

  echo HELLO_WORLD;

  $headers = apache_request_headers();
?>

<pre>
<?
  foreach ($headers as $header => $value) {
      echo "$header: $value \n";
  }
?>
</pre>

<pre>
<?
try {

  if( METHOD == 'POST' ){
    $sig = $headers['X-Hub-Signature'];

    echo var_dump(USER_AGENT);
    echo var_dump(QUERY_STRING);
    echo var_dump(POSTS);
    echo var_dump(REQ);

    if( $_REQUEST['event'] == "push" ){ 
      //$out = shell_exec("git pull origin master > ~/php-debug.log 2>&1");
      $out = shell_exec("git pull origin master");
      echo "PUSH IT! > yay > {$_REQUEST['event']} \n";
      echo "out:$out\n";
      echo "sig:$sig\n";
    }

  }else{

    echo var_dump(REQ);
    if( $_REQUEST['event'] == "push" ){ 
      echo "GET PUSH IT! > {$_REQUEST['event']}";
    }
  }

} catch (Exception $e) {
  echo 'Caught exception: ',  $e->getMessage(), "\n";
}

?>
</pre>
