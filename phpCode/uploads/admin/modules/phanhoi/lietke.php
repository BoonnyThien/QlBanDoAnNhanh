<?php
$sql_phanhoi = "SELECT * FROM tbl_phanhoi ORDER BY id_ph DESC";
$query_phanhoi = mysqli_query($mysqli, $sql_phanhoi);
?>
<p style="text-align: center;font-weight: bold;font-size: 30px;margin-top: 30px;">Ý kiến phản hồi</p>
<table style="width: 90%;margin: 0 auto;" class="table table-bordered table-hover">
    <thead class="" style="background-color: #000; color:#fff;">
        <tr>
            <th>ID</th>
            <th>Tên</th>
            <th>Email</th>
            <th>Ý kiến phản hồi</th>
            <th>Tình trạng</th>
        </tr>
    </thead>
    <?php
    $i = 0;
    while ($row = mysqli_fetch_array($query_phanhoi)) {
        $i++;
    ?>
    <tr>
        <td><?php echo $i ?></td>
        <td><?php echo $row['hoten'] ?></td>
        <td><?php echo $row['email'] ?></td>
        <td><?php echo $row['noidung'] ?></td>
        <td>
            <?php
				if ($row['status'] == 1) {
					echo '<a href="modules/phanhoi/xuly.php?id=' . $row['id_ph'] . '">Chưa xem</a>';
				} else {
					echo  'Đã xem';
				}
				?>
        </td>
    </tr>
    <?php
    }
    ?>

</table>