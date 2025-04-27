<?php
ob_start();
session_start();
if (!isset($_SESSION['dangnhap'])) {
    header('Location: login.php');
    exit();
}

$protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? "https" : "http";
$uri = rtrim(dirname($_SERVER['SCRIPT_NAME']), '/\\');
$admin_base = $protocol . '://' . $_SERVER['HTTP_HOST'] . $uri . '/';

?>
<!DOCTYPE html>
<html lang="vi">

<head>
    <base href="<?php echo $admin_base; ?>">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Trang Admin</title>
    
    <!-- Font Awesome (chỉ dùng 1 phiên bản) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    
    <!-- CSS từ CDN -->
    <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/morris.js/0.5.1/morris.css">
    
    <!-- Favicon (đường dẫn tuyệt đối từ root) -->
    <link rel="shortcut icon" href="./assets/img/icon.png" type="image/x-icon" />
    
    <!-- AdminLTE và plugins (đường dẫn tuyệt đối từ base) -->
    <link rel="stylesheet" href="Public/Admin/plugins/tempusdominus-bootstrap-4/css/tempusdominus-bootstrap-4.min.css">
    <link rel="stylesheet" href="Public/Admin/plugins/icheck-bootstrap/icheck-bootstrap.min.css">
    <link rel="stylesheet" href="Public/Admin/plugins/jqvmap/jqvmap.min.css">
    <link rel="stylesheet" href="Public/Admin/dist/css/adminlte.min.css">
    <link rel="stylesheet" href="Public/Admin/plugins/overlayScrollbars/css/OverlayScrollbars.min.css">
    <link rel="stylesheet" href="Public/Admin/plugins/daterangepicker/daterangepicker.css">
    <link rel="stylesheet" href="Public/Admin/plugins/summernote/summernote-bs4.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700" rel="stylesheet">
    
    <!-- Custom CSS (đường dẫn tuyệt đối từ base) -->
    <link rel="stylesheet" href="<?php echo $admin_base; ?>assets/style/index.css">
    <link rel="stylesheet" href="style/formdangky.css">
</head>

<body class="hold-transition sidebar-mini layout-fixed">
    <div class="wrapper">
        <?php
        require_once __DIR__ . '/config/config.php';
        include("modules/header.php");
        include("modules/main.php");
        ?>
    </div>

    <!-- jQuery và các thư viện cơ bản -->
    <script src="Public/Admin/plugins/jquery/jquery.min.js"></script>
    <script src="Public/Admin/plugins/jquery-ui/jquery-ui.min.js"></script>
    <script src="Public/Admin/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
    
    <!-- Các plugin khác -->
    <script src="Public/Admin/plugins/chart.js/Chart.min.js"></script>
    <script src="Public/Admin/plugins/sparklines/sparkline.js"></script>
    <script src="Public/Admin/plugins/jqvmap/jquery.vmap.min.js"></script>
    <script src="Public/Admin/plugins/jqvmap/maps/jquery.vmap.usa.js"></script>
    <script src="Public/Admin/plugins/jquery-knob/jquery.knob.min.js"></script>
    <script src="Public/Admin/plugins/moment/moment.min.js"></script>
    <script src="Public/Admin/plugins/daterangepicker/daterangepicker.js"></script>
    <script src="Public/Admin/plugins/tempusdominus-bootstrap-4/js/tempusdominus-bootstrap-4.min.js"></script>
    <script src="Public/Admin/plugins/summernote/summernote-bs4.min.js"></script>
    <script src="Public/Admin/plugins/overlayScrollbars/js/jquery.overlayScrollbars.min.js"></script>
    
    <!-- AdminLTE -->
    <script src="Public/Admin/dist/js/adminlte.js"></script>
    <script src="Public/Admin/dist/js/pages/dashboard.js"></script>
    
    <!-- Morris.js -->
    <script src="//cdnjs.cloudflare.com/ajax/libs/raphael/2.1.0/raphael-min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/morris.js/0.5.1/morris.min.js"></script>
    
    <!-- Custom JS -->
    <script src="JS/thongke.js"></script>
    
    <!-- IonIcons -->
    <script src="https://unpkg.com/ionicons@5.0.0/dist/ionicons.js"></script>
    
    <script>
    $.widget.bridge('uibutton', $.ui.button);
    </script>
</body>

</html>