<?php
$sql_lietke_cmt = "SELECT * FROM tbl_comments,tbl_sanpham WHERE tbl_comments.id_sp = tbl_sanpham.id_sp ORDER BY tbl_comments.id_cmt DESC";
$query_lietke_cmt = mysqli_query($mysqli, $sql_lietke_cmt);
?>
<p style="text-align: center;font-weight: bold;font-size: 30px;margin-top: 30px;">Danh sách bình luận</p>
<table style="width: 90%;margin: 0 auto;" class="table table-bordered table-hover">
    <thead class="" style="background-color: #000; color:#fff;">
        <tr>
            <th>ID</th>
            <th>Tên</th>
            <th>Email</th>
            <th>Nội dung đánh giá</th>
            <th>Mã sản phẩm</th>
            <th>Ảnh sản phẩm</th>
            <th>Quản lý</th>
        </tr>
    </thead>
    <?php
    $i = 0;
    while ($row = mysqli_fetch_array($query_lietke_cmt)) {
        $i++;
    ?>
    <tr>
        <td><?php echo $i ?></td>
        <td><?php echo $row['name'] ?></td>
        <td><?php echo $row['name_email'] ?></td>
        <td><?php echo $row['noidung'] ?></td>
        <td><?php echo $row['masp'] ?></td>
        <td><?php echo $row['tensp'] ?></td>
        <td>
            <a href="modules/quanlycmt/xuly.php?idcmt=<?php echo $row['id_cmt']?>">Xóa</a>
        </td>
    </tr>
    <?php
    }
    ?>

</table>