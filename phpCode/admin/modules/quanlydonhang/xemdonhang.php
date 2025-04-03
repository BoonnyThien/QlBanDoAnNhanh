<?php
$code = $_GET['code'];
$sql_lietke_donhang = "SELECT * FROM tbl_cart_details,tbl_sanpham WHERE tbl_cart_details.id_sp = tbl_sanpham.id_sp AND tbl_cart_details.code_cart='" . $code . "' ORDER BY tbl_cart_details.id_cart_details DESC";
$query_lietke_donhang = mysqli_query($mysqli, $sql_lietke_donhang);
?>
<p style="text-align: center;font-weight: bold;font-size: 30px;margin-top: 30px;">xem đơn hàng</p>
<table style="width: 90%; margin: 0 auto;" class="table table-bordered">
    <thead class="table-primary">
        <tr>
            <th>ID</th>
            <th>Mã đơn hàng</th>
            <th>Tên sản phẩm</th>
            <th>Số lượng</th>
            <th>Đơn sản phẩm</th>
            <th>Đơn sale</th>
            <th>Thành tiền</th>
        </tr>
    </thead>
    <?php
	$i = 0;
	$tongtien = 0;
	while ($row = mysqli_fetch_array($query_lietke_donhang)) {
		$i++;
        if($row['gia_sale']>0){
        $thanhtien = $row['soluongmua'] * $row['gia_sale'];
        $tongtien += $thanhtien;
        $i++;
        }else{
        $thanhtien = $row['soluongmua'] * $row['giasp'];
        $tongtien += $thanhtien;
        $i++;
        }
	?>
    <tr>
        <td><?php echo $i ?></td>
        <td><?php echo $row['code_cart'] ?></td>
        <td><?php echo $row['tensp'] ?></td>
        <td><?php echo $row['soluongmua'] ?></td>
        <td><?php echo number_format($row['giasp'], 0, ',', '.') . 'vnđ' ?></td>
        <td><?php echo number_format($row['gia_sale'], 0, ',', '.') . 'vnđ' ?></td>
        <td><?php echo number_format($thanhtien, 0, ',', '.') . 'vnđ' ?></td>
    </tr>
    <?php
	}
	?>
    <tr>
        <td colspan="7">
            <p style="float: right;">Tổng tiền: <?php echo number_format($tongtien, 0, ',', '.') . 'vnđ' ?></p>
        </td>
    </tr>

</table>
<div style="clear: both;"></div>