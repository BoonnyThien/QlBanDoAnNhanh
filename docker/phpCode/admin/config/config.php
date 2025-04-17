<?php
// Hiển thị tất cả lỗi
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Thiết lập timezone
date_default_timezone_set('Asia/Ho_Chi_Minh');

// Thiết lập encoding cho PHP
mb_internal_encoding('UTF-8');
mb_http_output('UTF-8');
mb_regex_encoding('UTF-8');


try {
    // Kết nối MySQL
    $mysqli = new mysqli("mysql-service", "app_user", "userpass", "qlbandoannhanh");

if ($mysqli->connect_error) {
    die("Lỗi kết nối: " . $mysqli->connect_error);
}
echo "Kết nối thành công!";


} catch (Exception $e) {
    echo "<div style='color:red'>Lỗi: " . $e->getMessage() . "</div>";
}
?>
