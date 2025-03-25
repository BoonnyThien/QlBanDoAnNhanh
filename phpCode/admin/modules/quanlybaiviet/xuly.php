<?php
include('../../config/config.php');

$tieude = $_POST['tieude'];
//xu ly hinh anh
$img = $_FILES['img_baiviet']['name'];
$img_tmp = $_FILES['img_baiviet']['tmp_name'];
$img = time() . '_' . $img;
$tomtat = $_POST['tomtat'];
$noidung = $_POST['noidung'];
$ngayviet = $_POST['ngayviet'];


if (isset($_POST['thembaiviet'])) {
	//them
	$sql_them = "INSERT INTO tbl_baiviet(tieude,img_baiviet,tomtat,noidung,ngayviet) VALUES('" . $tieude . "','" . $img . "','" . $tomtat . "','" . $noidung . "','" . $ngayviet . "')";
	mysqli_query($mysqli, $sql_them);
	move_uploaded_file($img_tmp, 'img_post/' . $img);
	header('Location:../../index.php?action=quanlybaiviet&query=lietke');
} elseif (isset($_POST['suabaiviet'])) {
	//sua
	if ($img != '') {
		move_uploaded_file($img_tmp, 'img_post/' . $img);
		//xoa hinh anh cu
		$sql = "SELECT * FROM tbl_baiviet WHERE id_baiviet = '$_GET[idbaiviet]' LIMIT 1";
		$query = mysqli_query($mysqli, $sql);
		while ($row = mysqli_fetch_array($query)) {
			unlink('img_post/' . $row['img_baiviet']);
		}
		$sql_update = "UPDATE tbl_baiviet SET tieude='" . $tieude . "',img_baiviet='" . $img . "',tomtat='" . $tomtat . "',noidung='" . $noidung . "',ngayviet='" . $ngayviet . "' WHERE id_baiviet ='$_GET[idbaiviet]'";
	} else {
		$sql_update = "UPDATE tbl_baiviet SET tieude='" . $tieude . "',tomtat='" . $tomtat . "',noidung='" . $noidung . "',ngayviet='" . $ngayviet . "', WHERE id_baiviet ='$_GET[idbaiviet]'";
	}
	mysqli_query($mysqli, $sql_update);
	header('Location:../../index.php?action=quanlybaiviet&query=lietke');
} else {
	$id = $_GET['idbaiviet'];
	$sql = "SELECT * FROM tbl_baiviet WHERE id_baiviet = '$id' LIMIT 1";
	$query = mysqli_query($mysqli, $sql);
	while ($row = mysqli_fetch_array($query)) {
		unlink('img_post/' . $row['img_baiviet']);
	}
	$sql_xoa = "DELETE FROM tbl_baiviet WHERE id_baiviet ='" . $id . "'";
	mysqli_query($mysqli, $sql_xoa);
	header('Location:../../index.php?action=quanlybaiviet&query=lietke');
}