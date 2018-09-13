<?php 

define("HELLO_WORLD", "Hello there API hook.");
define("QUERY_STRING", $_SERVER['QUERY_STRING']);
define("USER_AGENT", $_SERVER['HTTP_USER_AGENT']);
define("REQ", $_REQUEST);
define("GETS", $_GET);
define("POSTS", $_POST);
define("METHOD", $_SERVER['REQUEST_METHOD']);
define("PUSHKEY", getenv('GIT_PUSH_KEY') || 0 );

  echo HELLO_WORLD;
  echo "YAY BABY";

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
    $shasig = sha1(PUSHKEY);

    echo var_dump(USER_AGENT);
    echo var_dump(QUERY_STRING);
    echo var_dump(POSTS);
    echo var_dump(REQ);

    print_r(explode('=',$sig,0));

    if( $_REQUEST['event'] == "push" ){ 
      //$out = shell_exec("git pull origin master > ~/php-debug.log 2>&1");
      $out = shell_exec("git pull origin master 2>&1 | tee -a ~/php-debug.log");
      
      echo "PUSH IT! > yay > {$_REQUEST['event']} \n";
      echo "out:$out\n";
      echo "sig:$sig :: $shasig \n";

      $rev = shell_exec("git rev-list HEAD --count ");
      echo "vers:$rev\n";
    }

  }else{

    echo var_dump(REQ);
    
    $usig = $_REQUEST['usig'];
    $sig  = $_REQUEST['sig'] || sha1($usig) || null;
    $shasig = sha1(PUSHKEY);

    if( $_REQUEST['event'] == "push" ){ 
      $rev = shell_exec("git rev-list HEAD --count");
      echo "GET PUSH IT! > {$_REQUEST['event']}";
      echo "vers:$rev\n";
      echo "sig:$sig :: $shasig \n";
      echo PUSHKEY;
    }
  }

} catch (Exception $e) {
  echo 'Caught exception: ',  $e->getMessage(), "\n";
}

?>
</pre>
