<?php
// Hiển thị tất cả lỗi
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

try {
    // Kết nối MySQL
    $mysqli = new mysqli(
        "mysql_db",     // Tên service từ docker-compose.yml
        "app_user",     // User đã khai báo
        "userpass",     // Mật khẩu đã khai báo
        "qlbandoannhanh" // Database đã khai báo
    );
    $mysqli->set_charset("utf8mb4");

    if ($mysqli->connect_errno) {
        throw new Exception("Kết nối thất bại: " . $mysqli->connect_error);
    }

    echo "<div style='color:green'>Kết nối thành công!</div>";

} catch (Exception $e) {
    echo "<div style='color:red'>Lỗi: " . $e->getMessage() . "</div>";
}
?>
