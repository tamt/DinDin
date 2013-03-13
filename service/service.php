<?php
$op = $_GET['op'];
if ($op == 'setid') {
    $id = $_GET['id'];
    echo file_put_contents('id.txt', $id);
} else if ($op == 'getid') {
    $file = fopen("id.txt", "r");
    echo fgets($file);
    fclose($file);
}else{

}
