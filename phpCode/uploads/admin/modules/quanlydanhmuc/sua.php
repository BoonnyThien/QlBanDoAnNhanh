<?php
$sql_sua_danhmucsp = "SELECT * FROM tbl_danhmuc WHERE id_danhmuc='$_GET[iddanhmuc]' LIMIT 1";
$query_sua_danhmucsp = mysqli_query($mysqli, $sql_sua_danhmucsp);
?>
<p style="text-align: center;font-weight: bold;font-size: 30px;margin-top: 30px;">Sửa danh mục sản phẩm</p>
<table border="1" style="width: 50%;margin: 0 auto;" class="table table-bordered">
    <form method="POST" action="modules/quanlydanhmuc/xuly.php?iddanhmuc=<?php echo $_GET['iddanhmuc'] ?>">
        <?php
		while ($dong = mysqli_fetch_array($query_sua_danhmucsp)) {
		?>
        <tr>
            <td>Tên danh mục</td>
            <td><input type="text" size="35" value="<?php echo $dong['tendanhmuc'] ?>" name="tendanhmuc"></td>
        </tr>
        <tr>
            <td>Thứ tự</td>
            <td><input type="text" size="35" value="<?php echo $dong['thutu'] ?>" name="thutu"></td>
        </tr>
        <tr>
            <td colspan="2"><input type="submit" style="margin-left: 35%;" name="suadanhmuc"
                    value="Sửa danh mục sản phẩm"></td>
        </tr>
        <?php
		}
		?>
    </form>
</table>