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

// Thiết lập encoding cho HTTP input
if (function_exists('mb_http_input')) {
    mb_http_input('G');
    mb_http_input('P');
    mb_http_input('C');
}

try {
    // Kết nối MySQL
    $mysqli = new mysqli(
        "mysql-service",     // Tên service từ docker-compose.yml
        "app_user",     // User đã khai báo
        "userpass",     // Mật khẩu đã khai báo
        "qlbandoannhanh" // Database đã khai báo
    );

    if ($mysqli->connect_errno) {
        throw new Exception("Kết nối thất bại: " . $mysqli->connect_error);
    }

    // Thiết lập charset và collation
    $mysqli->set_charset("utf8mb4");
    $mysqli->query("SET NAMES utf8mb4");
    $mysqli->query("SET CHARACTER SET utf8mb4");
    $mysqli->query("SET COLLATION_CONNECTION = 'utf8mb4_unicode_ci'");

    // Thiết lập header cho UTF-8
    header('Content-Type: text/html; charset=UTF-8');

} catch (Exception $e) {
    echo "<div style='color:red'>Lỗi: " . $e->getMessage() . "</div>";
}
?>
