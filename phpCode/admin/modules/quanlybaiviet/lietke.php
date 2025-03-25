<?php
$sql_lietke_baiviet = "SELECT * FROM tbl_baiviet  ORDER BY id_baiviet ASC";
$query_lietke_baiviet = mysqli_query($mysqli, $sql_lietke_baiviet);
?>
<p style="text-align: center;font-weight: bold;font-size: 30px;margin-top: 30px;">Danh sách bài viết</p>
<table style="width: 90%; margin: 0 auto;" class="table table-bordered table-hover">
    <thead class="" style="background-color: #000; color:#fff;">
        <tr>
            <th>ID</th>
            <th>Tiêu đề</th>
            <th>Hình ảnh</th>
            <th>Tóm tắt</th>
            <th>Nội Dung</th>
            <th>Ngày viết</th>
            <th>Quản lý</th>
        </tr>
    </thead>
    <?php
	$i = 0;
	while ($row = mysqli_fetch_array($query_lietke_baiviet)) {
		$i++;
	?>
    <tr>
        <td><?php echo $i ?></td>
        <td><?php echo $row['tieude'] ?></td>
        <td><img src="modules/quanlybaiviet/img_post/<?php echo $row['img_baiviet'] ?>" width="250px"></td>
        <td><?php echo $row['tomtat'] ?></td>
        <td><?php echo $row['noidung'] ?></td>
        <td><?php echo $row['ngayviet'] ?></td>
        <td>
            <a style="margin-right: 5px;"
                href="modules/quanlybaiviet/xuly.php?idbaiviet=<?php echo $row['id_baiviet'] ?>"><i
                    class="fa-solid fa-trash-can"></i></a> | <a style="margin-left:5px"
                href="?action=quanlybaiviet&query=sua&idbaiviet=<?php echo $row['id_baiviet'] ?>"><i
                    class="fas fa-edit"></i></a>
        </td>
    </tr>
    <?php
	}
	?>

</table>