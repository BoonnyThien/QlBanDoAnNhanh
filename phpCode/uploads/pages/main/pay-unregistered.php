<?php
ob_start();
session_start();

use Carbon\Carbon;

include("../../admin/config/config.php");
require('../../Carbon/autoload.php');
$now = Carbon::now('Asia/Ho_Chi_Minh')->toDateString();


if(isset($_POST['order'])){
    $hoten = $_POST['ten'];
    $diachi = $_POST['diachi'];
    $email = $_POST['email'];
    $sdt = $_POST['sdt'];
    $noidung = $_POST['noidung'];
    $code_order = rand(0,9999);
    $insert_cart_unregistered = "INSERT INTO tbl_cart_unregistered(tenkh, diachi,sdt ,email,noidung,code_cart,cart_status,cart_date ) VALUE ('".$hoten."','".$diachi."','".$sdt."','".$email."','".$noidung."','".$code_order."',1,'".$now."')";
    $cart_query_unregistered = mysqli_query($mysqli, $insert_cart_unregistered);
    if($cart_query_unregistered){
        foreach ($_SESSION['cart'] as $key => $value) {
            $id_sanpham = $value['id'];
            $soluong = $value['soluong'];
            $insert_order_details = "INSERT INTO tbl_cart_details(id_sp,code_cart,soluongmua) VALUE('" . $id_sanpham . "','" . $code_order . "','" . $soluong . "')";
            mysqli_query($mysqli, $insert_order_details);
        }
    }
}
unset($_SESSION['cart']);
header('Location:../../index.php?quanly=camon');
?>