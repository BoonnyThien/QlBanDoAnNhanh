<?php
ob_start();
session_start();
include('../../config/config.php');
if (isset($_POST['dangky'])) {
	$name = $_POST['name'];
	$taikhoan = $_POST['username'];
	$matkhau = md5($_POST['password']);
	$sql_dangky = mysqli_query($mysqli, "INSERT INTO tbl_admin(nameadmin,username,password,admin_status) VALUES ('" . $name . "','" . $taikhoan . "','" . $matkhau . "',1)");
	if($sql_dangky){
		header("Location:../../index.php");
		$_SESSION['dangky'] = $name;
	}
}
?>