<?php
$sql_lietke_sp = "SELECT * FROM tbl_sanpham,tbl_danhmuc WHERE tbl_sanpham.id_danhmuc=tbl_danhmuc.id_danhmuc ORDER BY id_sp DESC";
$query_lietke_sp = mysqli_query($mysqli, $sql_lietke_sp);
?>
<p style="text-align: center;font-weight: bold;font-size: 30px;margin-top: 30px;">Danh sách sản phẩm</p>
<table style="width: 95%; margin: 0 auto;" class="table table-bordered table-hover">
    <thead class="" style="background-color: #000; color:#fff;">
        <tr>
            <th>ID</th>
            <th>Tên sản phẩm</th>
            <th>Hình ảnh</th>
            <th>Giá sản phẩm</th>
            <th>Giá sale</th>
            <th>Danh mục</th>
            <th>Mã sản phẩm</th>
            <th>Mô tả</th>
            <th>Trạng thái</th>
            <th>Quản lý</th>
        </tr>
    </thead>
    <?php
	$i = 0;
	while ($row = mysqli_fetch_array($query_lietke_sp)) {
		$i++;
	?>
    <tr>
        <td><?php echo $i ?></td>
        <td><?php echo $row['tensp'] ?></td>
        <td><img src="modules/quanlysp/uploads/<?php echo $row['hinhanh'] ?>" width="150px"></td>
        <td><?php echo $row['giasp'] ?></td>
        <td><?php echo $row['gia_sale'] ?></td>
        <td><?php echo $row['tendanhmuc'] ?></td>
        <td><?php echo $row['masp'] ?></td>
        <td><?php echo $row['mota'] ?></td>
        <td><?php if ($row['tinhtrang'] == 1) {
					echo 'kích hoạt';
				} else {
					echo 'ẩn';
				} ?>
        </td>
        <td>
            <a href="modules/quanlysp/xuly.php?idsanpham=<?php echo $row['id_sp'] ?>"><i
                    class="fa-solid fa-trash-can"></i></a> | <a
                href="?action=quanlysp&query=sua&idsanpham=<?php echo $row['id_sp'] ?>"><i class="fas fa-edit"></i></a>
        </td>
    </tr>
    <?php
	}
	?>

</table>