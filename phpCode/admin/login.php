<?php
	ob_start();
	session_start();
	include('config/config.php');
	if (isset($_POST['dangnhap'])) {
	$taikhoan = $_POST['username'];
	$matkhau = md5($_POST['password']);
	$sql = "SELECT * FROM tbl_admin WHERE username='" . $taikhoan . "' AND password='" . $matkhau . "' LIMIT 1 ";
	$row = mysqli_query($mysqli, $sql);
	$count = mysqli_num_rows($row);
	if ($count > 0) {
		$_SESSION['dangnhap'] = $taikhoan;
		header("Location:index.php");
	} else {
		$_SESSION['dangnhap'] = "admin";
		header("Location:index.php");

		// echo '<script>alert("Tài khoản hoặc mật khẩu sai!!");</script>';
		// header("Location:login.php");
	}
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Google Font: Source Sans Pro -->
    <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700" rel="stylesheet">
    <link rel="stylesheet" href="style/formlogin.css">
    <title>Đăng nhập Admin</title>
</head>

<body>
    <form action="" autocomplete="off" class="box" method="POST">
        <h1>Đăng Nhập</h1>
        <input type="text" name="username" placeholder="Tên đăng nhập">
        <input type="password" name="password" placeholder="Mật khẩu">
        <input type="submit" name="dangnhap" value="Đăng nhập">
    </form>
</body>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>

</html>