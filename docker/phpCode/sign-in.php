<?php
ob_start();
session_start();
include("admin/config/config.php");

if (isset($_POST['dangnhap'])) {
    $reenter = $_POST['nhaplai'];
    $email = $_POST['email'];
    $matkhau = md5($_POST['matkhau']);
    $sql = "SELECT * FROM tbl_dangky WHERE email='" . $email . "' AND matkhau='" . $matkhau . "' LIMIT 1 ";
    $row = mysqli_query($mysqli, $sql);
    $count = mysqli_num_rows($row);

    $ischeck = false;

    //so sánh mật khẩu nhập lại
    if ($reenter != $_POST['matkhau']) {
        $ischeck = true;
    }

    if ($count > 0 && $ischeck == false) {
        $row_data = mysqli_fetch_array($row);
        $_SESSION['dangky'] = $row_data['tenkhachhang'];
        $_SESSION['id_khachhang'] = $row_data['id_dangky'];
        header("Location:index.php");
    } else {
        echo '<script>alert("Tài khoản hoặc mật khẩu sai!!");</script>';
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
                    <input type="email" class="field" name="email" placeholder="Email">
                    <input type="password" class="field" name="matkhau" placeholder="Mật khẩu">
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