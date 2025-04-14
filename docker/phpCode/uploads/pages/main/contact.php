<?php
if (isset($_POST['phanhoi'])) {
    $tenkh = $_POST['ten'];
    $email = $_POST['email'];
    $noidung = $_POST['noidung'];
    $sql_phanhoi = mysqli_query($mysqli, "INSERT INTO tbl_phanhoi(hoten,email,noidung,status) VALUES ('" . $tenkh . "','" . $email . "','" . $noidung . "',1)");
    if ($sql_phanhoi) {
        echo '<script>alert("Cám ơn với góp ý của bạn !!!");</script>';
    }
}
?>
<div class="page-contact">
    <div class="page-contact-heading">
        <img src="././assets/img/banner1.jpg" alt="" class="page-contact-heading-img">
        <div class="page-contact-heading-text">
            <h2 style="color: black;">Liên Hệ</h2>
            <p style="color: black;">Trang chủ > Liên hệ</p>
        </div>
    </div>
    <div class="page-contact-body">
        <div class="contact-form">
            <form action="" class="contact-form-left" method="POST">
                <h2>Liên hệ</h2>
                <div class="contact-form-left-name">
                    <input type="text" name="ten" required id="" placeholder="Họ và tên">
                    <input type="email" name="email" required id="" placeholder="Email">
                </div>
                <textarea name="noidung" required id="" cols="30" rows="10" class="contact-form-left-message"
                    placeholder="Nội dung..."></textarea><br>
                <input type="submit" name="phanhoi" value=" Gửi đi" class="contact-form-left-submit">
            </form>
            <div class="contact-form-right">
                <h2>Liên hệ với chúng tôi</h2>
                <div class="contact-form-right-address">
                    <i class="fa-solid fa-location-dot"></i>
                    <p>
                        <strong>Địa chỉ: </strong>
                        Trường Đại Học Kinh Tế Kỹ Thuật Công Nghiệp
                    </p>
                </div>
                <div class="contact-form-right-phone">
                    <i class="fa-solid fa-phone"></i>
                    <p>
                        <strong>Điện thoại: </strong>
                        +84 789388656
                    </p>
                </div>
                <div class="contact-form-right-email">
                    <i class="fa-solid fa-paper-plane"></i>
                    <p>
                        <strong>Email: </strong>
                        nvhiep.dhti15a23hn@sv.uneti.edu.vn
                    </p>
                </div>
                <div class="contact-form-right-website">
                    <i class="fa-solid fa-earth-asia"></i>
                    <p>
                        <strong>Website: </strong>
                        CuaHangBanDoAnNhanh.com
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>