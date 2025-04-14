<?php
    include("././admin/config/config.php");
    if (isset($_POST['addcomment'])) {
        $id = $_GET['id'];
        $name = $_POST['name'];
        $name_email = $_POST['name_email'];
        $noidung = $_POST['noidung'];
        $sql_cmt = mysqli_query($mysqli, "INSERT INTO tbl_comments(name,name_email,noidung,id_sp) VALUES ('".$name."','".$name_email."','".$noidung."','".$id."')");
    }
?>
<?php
    $sql_desc = "SELECT * FROM tbl_sanpham,tbl_danhmuc WHERE tbl_sanpham.id_danhmuc = tbl_danhmuc.id_danhmuc AND tbl_sanpham.id_sp = '$_GET[id]' LIMIT 1";
    $query_desc = mysqli_query($mysqli,$sql_desc);
?>
<?php
    $sql_pro_bonnus = "SELECT * FROM tbl_sanpham,tbl_danhmuc WHERE tbl_sanpham.id_danhmuc = tbl_danhmuc.id_danhmuc AND tbl_sanpham.id_danhmuc = '$_GET[iddm]' LIMIT 5";
    $query_pro_bonnus = mysqli_query($mysqli, $sql_pro_bonnus);
?>
<?php
    $sql_comment = "SELECT * FROM tbl_sanpham,tbl_comments WHERE tbl_sanpham.id_sp=tbl_comments.id_sp AND tbl_comments.id_sp='$_GET[id]' ORDER BY tbl_comments.id_cmt DESC";
    $query_comment = mysqli_query($mysqli, $sql_comment);
?>
<div class="page-product">
    <div class="page-product-heading">
        <img src="././assets/img/banner1.jpg" alt="" class="page-product-heading-img">
        <div class="page-product-heading-text">
            <h2 style="color: black;">Sản Phẩm</h2>
            <p style="color: black;" >Trang chủ > Sản phẩm</p>
        </div>
    </div>
    <?php
    while($row_desc = mysqli_fetch_array($query_desc)){
    ?>
    <div class="page-product-body">
        <div class="page-product-body-left">
            <img src="admin/modules/quanlysp/uploads/<?php echo $row_desc['hinhanh'] ?>" alt=""
                class="page-product-body-left-img">
        </div>
        <form action="pages/main/addtocart.php?id=<?php echo $row_desc['id_sp'] ?>" method="POST">
            <div class="page-product-body-right">
                <h2 class="page-product-body-right-title">
                    <?php echo $row_desc['tensp']?>
                </h2>
                <p class="page-product-body-right-cate">
                    <?php echo $row_desc['tendanhmuc']?>
                </p>
                <div class="page-product-body-right-star">
                    <i class="fa-solid fa-star"></i>
                    <i class="fa-solid fa-star"></i>
                    <i class="fa-solid fa-star"></i>
                    <i class="fa-solid fa-star"></i>
                    <i class="fa-solid fa-star"></i>
                </div>
                <?php
                    if($row_desc['gia_sale']>0){
                ?>
                <p style="text-decoration: line-through;" class="page-product-body-right-price">
                    Giá: <?php echo number_format($row_desc['giasp'],0,'.','.')." vnđ" ?>
                </p>
                <p class="page-product-body-right-price-sale">
                    Giá sale: <?php echo number_format($row_desc['gia_sale'],0,'.','.')." vnđ" ?>
                </p>
                <?php
                }else{
                ?>
                <p class="page-product-body-right-price">
                    Giá: <?php echo number_format($row_desc['giasp'],0,'.','.')." vnđ" ?>
                </p>
                <?php
                }
                ?>
                <p class="page-product-body-right-desc">
                    <?php echo $row_desc['mota']?>
                </p>
                <input type="submit" name="themgiohang" value=" +Thêm Giỏ Hàng" class="page-product-body-right-cart">
                <div class="page-product-body-right-social">
                    <p>Share</p>
                    <div class="page-product-body-right-social-list">
                        <i class="fa-brands fa-facebook"></i>
                        <i class="fa-brands fa-twitter"></i>
                        <i class="fa-brands fa-google"></i>
                        <i class="fa-brands fa-instagram"></i>
                    </div>
                </div>
                <ul class="page-product-body-right-support">
                    <li class="page-product-body-right-support-item">
                        <i class="fa-solid fa-truck-fast"></i>
                        <p>Giao hàng miễn phí. Các hóa đơn trị giá 200k trở lên</p>
                    </li>
                    <li class="page-product-body-right-support-item">
                        <i class="fa-solid fa-right-left"></i>
                        <p>Hoàn trả miễn phí trong 9 ngày</p>
                    </li>
                    <li class="page-product-body-right-support-item">
                        <i class="fa-solid fa-credit-card"></i>
                        <p>Thanh toán của bạn được an toàn với chúng tôi</p>
                    </li>
                </ul>
            </div>
        </form>
    </div>
    <?php
    }
    ?>
</div>
<div class="container-similar-cmt">
    <div class="cmt-container">
        <!--//todo tab item -->
        <div class="tabs">
            <div class="tabs-item active">
                <i class="tab-icon fa-solid fa-face-grin-stars"></i>
                Khuyến mãi
            </div>
            <div class="tabs-item">
                <i class="tab-icon fa-solid fa-comment"></i>
                Đánh giá
            </div>
            <div class="tabs-item">
                <i class="tab-icon fa-solid fa-star"></i>
                Chính sách bảo hành
            </div>
            <div class="line"></div>
        </div>
        <!-- //todo tab content -->
        <div class="tab-content">
            <div class="tab-pane active">
                <h2>Khuyến mãi</h2>
                <div class="tab-pane-promotion">
                    <p>
                        <i class="tab-pane-promotion-icon fa-solid fa-1"></i>
                        Giảm giá 800,000đ khi mua qua các phương thức thanh toán điện tử (Không áp dụng kèm giảm giá qua VNPay, Moca)
                    </p>
                    <p>
                        <i class="tab-pane-promotion-icon fa-solid fa-2"></i>
                        Giảm thêm 5% khi mua cùng sản phẩm bất kỳ có giá cao hơn
                    </p>
                    <p>
                        <i class="tab-pane-promotion-icon fa-solid fa-3"></i>
                        Giảm 50% giá mua gói giao hàng theo giờ (Yêu cầu đặt hàng từ 4 sản phẩm trở lên)
                    </p>
                    <p>
                        <i class="tab-pane-promotion-icon fa-solid fa-4"></i>
                        Cơ hội giảm 50% giá combo cho hoá đơn Trị giá từ 5 triệu đến 8 triệu
                    </p>
                    <p>
                        <i class="tab-pane-promotion-icon fa-solid fa-5"></i>
                        Nhập mã TGDD12 giảm 5% tối đa 500.000đ cho hóa đơn từ 500.000đ khi thanh toán qua Ví Moca trên
                        ứng dụng Grab
                    </p>
                </div>
            </div>
            <div class="tab-pane">
                <h2>Đánh giá</h2>
                <?php
                while($row_cmt = mysqli_fetch_array($query_comment)){
                ?>
                <div class="tab-pane-cmt">
                    <i class="fa-solid fa-circle-user tab-pane-cmt-icon"></i>
                    <div class="tab-pane-cmt-desc">
                        <p><?php echo $row_cmt['name'] ?></p>
                        <p><?php echo $row_cmt['noidung'] ?></p>
                    </div>
                </div>
                <?php
                }
                ?>
                <?php
                    if(isset($_SESSION['dangky'])){
                    ?>
                <button class="btn-cmt js-btn-cmt">
                    Đánh Giá
                </button>
                <?php
                    }else{
                    ?>
                <button class="btn-cmt js-btn-cmt hide">
                    Đánh Giá
                </button>
                <?php
                    }
                    ?>
            </div>
            <div class="tab-pane">
                <h2>Chính sách bảo hành</h2>
                <p>Lorem ipsum, dolor sit amet consectetur adipisicing elit. Praesentium, aliquid officiis tenetur
                    reprehenderit dolorem, dolore sit, ea saepe temporibus debitis atque error non quisquam voluptas
                    voluptatibus minus tempora perspiciatis nisi.</p>
            </div>
        </div>
    </div>
    <div class="similar-product-container">
        <p>Sản phẩm tương tự</p>
        <?php
        while($row_pro_bonus = mysqli_fetch_array($query_pro_bonnus)){
        ?>
        <div class="similar-product-container-item">
            <img src="admin/modules/quanlysp/uploads/<?php echo $row_pro_bonus['hinhanh'] ?>" alt=""
                class="similar-product-container-item-img">
            <a href="#" class="similar-product-container-item-title">
                <?php echo $row_pro_bonus['tensp']?>
            </a>
            <?php
            if($row_pro_bonus['gia_sale']>0){
            ?>
            <p class="similar-product-container-item-price">
                <?php echo number_format($row_pro_bonus['gia_sale'],0,'.','.').' vnđ' ?>
            </p>
            <?php
            }else{
            ?>
            <p class="similar-product-container-item-price">
                <?php echo number_format($row_pro_bonus['giasp'],0,'.','.').' vnđ' ?>
            </p>
            <?php
            }
            ?>
        </div>
        <?php
        }
        ?>
    </div>
</div>
<div style="margin-bottom: 50px;"></div>
<div class="container-comment js-container-comment">
    <form class="form-comment js-form-comment" action="" method="POST">
        <p class="form-comment-heading">Hãy để lại feedback của bạn ở đây</p>
        <div class="form-comment-body">
            <p>Nhận xét của bạn *</p>
            <textarea name="noidung" id="" rows="10" placeholder="Hãy viết ý kiến của bạn..."></textarea>
        </div>
        <div class="form-comment-footer">
            <div class="form-comment-footer-left">
                <p>Tên *</p>
                <input type="text" name="name" id="" placeholder="Tên...">
            </div>
            <div class="form-comment-footer-right">
                <p>Email *</p>
                <input type="text" name="name_email" id="" placeholder="Email...">
            </div>
        </div>

        <input class="form-comment-submit" type="submit" value="Gửi đi" name="addcomment">
    </form>
</div>
<div class="go-to-top js-top">
    <a href="#top">
        <i class="fa-solid fa-up-long"></i>
    </a>
</div>

<script>
const btnComment = document.querySelector(".js-btn-cmt");
const formComment = document.querySelector(".js-container-comment");
const modalComment = document.querySelector(".js-form-comment");

function openCommentForm() {
    formComment.classList.add("open");
}

function closeCommentForm() {
    formComment.classList.remove("open")
}

btnComment.addEventListener("click", openCommentForm);
formComment.addEventListener("click", closeCommentForm);
modalComment.addEventListener("click", function(event) {
    event.stopPropagation();
})

window.addEventListener("scroll", function() {
    var goTop = document.querySelector(".js-top");
    goTop.classList.toggle("open", window.scrollY > 0);
});

const $ = document.querySelector.bind(document);
const $$ = document.querySelectorAll.bind(document);

const tabs = $$('.tabs-item');
const panes = $$('.tab-pane');

const tabActive = $('.tabs-item.active');
const line = $('.tabs .line');

tabs.forEach((tab, index) => {
    const pane = panes[index]

    tab.onclick = function() {
        $('.tabs-item.active').classList.remove("active");
        $('.tab-pane.active').classList.remove("active");

        line.style.left = this.offsetLeft + 'px';
        line.style.width = this.offsetWidth + 'px';

        this.classList.add("active");
        pane.classList.add("active");
    }
})
</script>