<?php
$sql_lietke_khachhang = "SELECT * FROM tbl_dangky  ORDER BY id_khachhang ASC";
$query_lietke_khachhang = mysqli_query($mysqli, $sql_lietke_khachhang);
?>
<p style="text-align: center;font-weight: bold;font-size: 30px;margin-top: 30px;">Danh sách tài khoản khách hàng</p>
<table style="width: 90%;margin: 0 auto;" class="table table-bordered table-hover">
    <thead class="" style="background-color: #000; color:#fff;">
        <tr>
            <th>ID</th>
            <th>Tên khách hàng</th>
            <th>Địa chỉ</th>
            <th>Email</th>
            <th>Số điện thoại</th>
        </tr>
    </thead>
    <?php
    $i = 0;
    while ($row = mysqli_fetch_array($query_lietke_khachhang)) {
        $i++;
    ?>
    <tr>
        <td><?php echo $i ?></td>
        <td><?php echo $row['tenkhachhang'] ?></td>
        <td><?php echo $row['diachi'] ?></td>
        <td><?php echo $row['email'] ?></td>
        <td><?php echo $row['dienthoai'] ?></td>
    </tr>
    <?php
    }
    ?>

</table>