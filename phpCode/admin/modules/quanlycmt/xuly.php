<?php
include('../..//config/config.php');

// Kiểm tra kết nối database
if (!isset($mysqli) || $mysqli->connect_errno) {
    die("Lỗi kết nối database");
}

// Kiểm tra tham số idcmt
if (!isset($_GET['idcmt']) || empty($_GET['idcmt'])) {
    die("Thiếu tham số idcmt");
}

$id = $_GET['idcmt'];

// Thực hiện xóa với prepared statement để tránh SQL injection
$sql_xoa = "DELETE FROM tbl_comments WHERE id_cmt = ?";
$stmt = $mysqli->prepare($sql_xoa);
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    header('Location:../../index.php?action=quanlycmt&query=lietke');
} else {
    die("Lỗi khi xóa bình luận: " . $mysqli->error);
}

$stmt->close();
?>