<?php
$sql_lietke_donhang = "SELECT * FROM tbl_cart_registered,tbl_dangky WHERE tbl_cart_registered.id_khachhang=tbl_dangky.id_khachhang ORDER BY tbl_cart_registered.id_cart_registered DESC";
$query_lietke_donhang = mysqli_query($mysqli, $sql_lietke_donhang);
?>
<p style="text-align: center;font-weight: bold;font-size: 30px;margin-top: 30px;">Danh sách đơn hàng</p>
<table style="width: 90%; margin: 0 auto;" class="table table-bordered table-hover">
    <thead class="" style="background-color: #000; color:#fff;">
        <tr>
            <th>ID</th>
            <th>Mã đơn hàng</th>
            <th>Tên khách hàng</th>
            <th>Địa chỉ</th>
            <th>Email</th>
            <th>Số điện thoại</th>
            <th>Tình trạng</th>
            <th>Quản lý</th>
        </tr>
    </thead>
    <?php
	$i = 0;
	while ($row = mysqli_fetch_array($query_lietke_donhang)) {
		$i++;
	?>
    <tr>
        <td><?php echo $i ?></td>
        <td><?php echo $row['code_cart'] ?></td>
        <td><?php echo $row['tenkhachhang'] ?></td>
        <td><?php echo $row['diachi'] ?></td>
        <td><?php echo $row['email'] ?></td>
        <td><?php echo $row['dienthoai'] ?></td>
        <td>
            <?php
				if ($row['cart_status'] == 1) {
					echo '<a href="modules/quanlydonhang/xulyddk.php?code=' . $row['code_cart'] . '">Đơn hàng mới</a>';
				} else {
					echo  'Đã xem';
				}
				?>
        </td>
        <td>
            <a href="index.php?action=donhang&query=xemdonhang&code=<?php echo $row['code_cart'] ?>">Xem đơn hàng</a>
        </td>
    </tr>
    <?php
	}
	?>

</table>