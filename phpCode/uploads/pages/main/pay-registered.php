<?php
ob_start();
session_start();
use Carbon\Carbon;
include('../../admin/config/config.php');
require('../../Carbon/autoload.php');
$now = Carbon::now('Asia/Ho_Chi_Minh')->toDateString();
$id_khachhang = $_SESSION['id_khachhang'];
$code_order = rand(0, 9999);
$insert_cart_registered = "INSERT INTO tbl_cart_registered(id_khachhang,code_cart,cart_status,cart_date) VALUE ('" . $id_khachhang . "','" . $code_order . "',1,'" . $now . "')";
$cart_query = mysqli_query($mysqli, $insert_cart_registered);
if ($cart_query) {
	//them gio hang chi tiet
	foreach ($_SESSION['cart'] as $key => $value) {
		$id_sanpham = $value['id'];
		$soluong = $value['soluong'];
		$insert_order_details = "INSERT INTO tbl_cart_details(id_sp,code_cart,soluongmua) VALUE('" . $id_sanpham . "','" . $code_order . "','" . $soluong . "')";
		mysqli_query($mysqli, $insert_order_details);
	}
}
unset($_SESSION['cart']);
header('Location:../../index.php?quanly=camon');
?>