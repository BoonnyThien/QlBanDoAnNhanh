<?php
ob_start();
session_start();
include("admin/config/config.php");

if (isset($_POST['dangnhap'])) {
    $email = trim($_POST['email']);
    $matkhau_raw = trim($_POST['matkhau']);

    if (empty($email) || empty($matkhau_raw)) {
        echo '<script>alert("Vui lòng nhập đầy đủ email và mật khẩu.");</script>';
    } else {
        $matkhau = md5($matkhau_raw);
        $sql = "SELECT * FROM tbl_dangky WHERE email='$email' AND matkhau='$matkhau' LIMIT 1";
        $result = mysqli_query($mysqli, $sql);
        $count = mysqli_num_rows($result);

        if ($count > 0) {
            $row_data = mysqli_fetch_array($result);
            $_SESSION['dangky'] = $row_data['tenkhachhang'];
            $_SESSION['id_khachhang'] = $row_data['id_dangky'];
            header("Location:index.php");
            exit();
        } else {
            echo '<script>alert("Tài khoản hoặc mật khẩu sai!");</script>';
        }
    }
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập</title>
    <link rel="stylesheet" href="./assets/style/base/reset.css">
    <link rel="stylesheet" href="./assets/style/sign-in.css">
</head>

<body>
    <form action="" method="POST">
        <div class="container_contact">
            <div class="contact-box">
                <div class="left">
                    <h2>Đăng nhập</h2>
                    <input type="email" class="field" name="email" placeholder="Email" required>
                    <input type="password" class="field" name="matkhau" placeholder="Mật khẩu" required>
                    <input type="password" class="field" name="nhaplai" placeholder="Nhập lại mật khẩu">
                    <input class="btn" type="submit" name="dangnhap" value="Đăng nhập"></input>
                    <p>Bạn chưa có tải khoản ?<a href="./sign-up.php"> Đăng ký</a></p>
                </div>
                <div class="right">
                </div>
            </div>
        </div>
    </form>
</body>

</html>