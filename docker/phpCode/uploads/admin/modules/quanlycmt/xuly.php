<?php
include('../..//config/config.php');

$id = $_GET['idcmt'];
$sql_xoa = "DELETE FROM tbl_comments WHERE id_cmt='".$id."'";
mysqli_query($mysqli,$sql_xoa);
header('Location:../../index.php?action=quanlycmt&query=lietke');
?>