<?php
include("../../config/config.php");
if(isset($_GET['id'])){
    $id_ph = $_GET['id'];
    $sql_update = "UPDATE tbl_phanhoi SET status=0  WHERE id_ph='".$id_ph."'";
    $query = mysqli_query($mysqli,$sql_update);

    header('Location:../../index.php?action=phanhoi&query=lietke');
}
?>