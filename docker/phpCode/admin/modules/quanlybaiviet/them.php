<p style="text-align: center;font-weight: bold;font-size: 30px;margin-top: 30px;">Thêm bài viết</p>
<table class="table table-bordered" style="width: 60%;margin: 0 auto;">
    <form method="POST" action="modules/quanlybaiviet/xuly.php" enctype="multipart/form-data">
        <tr>
            <td>Tiêu đề</td>
            <td><input type="text" size="45" name="tieude"></td>
        </tr>
        <tr>
            <td>Hình ảnh</td>
            <td><input type="file" name="img_baiviet"></td>
        </tr>
        <tr>
            <td>Tóm tắt</td>
            <td><textarea rows="9" cols="50" name="tomtat" style="resize: none;"></textarea></td>
        </tr>
        <tr>
            <td>Nội dung</td>
            <td><textarea rows="15" cols="50" name="noidung" style="resize: none;"></textarea></td>
        </tr>
        <tr>
            <td>Ngày viết</td>
            <td><input type="date" name="ngayviet"></td>
        </tr>
        <tr>
            <td colspan="2"><input type="submit" style="margin-left: 35%;" name="thembaiviet" value="Thêm bài viết">
            </td>
        </tr>
    </form>
</table>