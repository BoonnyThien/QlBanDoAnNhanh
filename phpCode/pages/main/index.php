<?php
$sql_pro_sale = "SELECT * FROM tbl_sanpham,tbl_danhmuc WHERE tbl_danhmuc.id_danhmuc = tbl_sanpham.id_danhmuc AND tbl_sanpham.gia_sale > '0' ORDER BY tbl_sanpham.id_sp ASC" ;
$query_pro_sale = mysqli_query($mysqli,$sql_pro_sale);
?>
<?php
$sql_pro_iphone = "SELECT * FROM tbl_sanpham,tbl_danhmuc WHERE tbl_danhmuc.id_danhmuc = tbl_sanpham.id_danhmuc AND tbl_sanpham.id_danhmuc='2' ORDER BY tbl_sanpham.id_sp ASC";
$query_pro_iphone = mysqli_query($mysqli,$sql_pro_iphone);
?>
<?php
$sql_pro_ipad = "SELECT * FROM tbl_sanpham,tbl_danhmuc WHERE tbl_danhmuc.id_danhmuc = tbl_sanpham.id_danhmuc AND tbl_sanpham.id_danhmuc='3' ORDER BY tbl_sanpham.id_sp ASC";
$query_pro_ipad = mysqli_query($mysqli,$sql_pro_ipad);
?>
<?php
$sql_post = "SELECT * FROM tbl_baiviet ORDER BY id_baiviet DESC";
$query_post = mysqli_query($mysqli,$sql_post);
?>
<!-- //todo slider -->
<div id="myCarousel" class="carousel slide border" data-ride="carousel">
    <ol class="carousel-indicators">
        <li data-target="#myCarousel" data-slide-to="0" class="active"></li>
        <li data-target="#myCarousel" data-slide-to="1"></li>
        <li data-target="#myCarousel" data-slide-to="2"></li>
    </ol>
    <div class="carousel-inner">
        <div class="carousel-item active">
            <img class="d-block w-100" src="./assets/img/banner1.jpg" alt="Leopard">
        </div>
        <div class="carousel-item">
            <img class="d-block w-100" src="./assets/img/banner2.jpg" alt="Cat">
        </div>
        <div class="carousel-item">
            <img class="d-block w-100" src="./assets/img/banner1.jpg" alt="Lion">
        </div>
    </div>
    <a class="carousel-control-prev" href="#myCarousel" role="button" data-slide="prev">
        <span class="carousel-control-prev-icon" aria-hidden="true"></span>
        <span class="sr-only">Previous</span>
    </a>
    <a class="carousel-control-next" href="#myCarousel" role="button" data-slide="next">
        <span class="carousel-control-next-icon" aria-hidden="true"></span>
        <span class="sr-only">Next</span>
    </a>
</div>
<!-- //todo support -->
<div class="container-support">
    <div class="container-support-item">
        <div class="container-support-item-icon">
            <i class="fa-solid fa-truck-fast"></i>
        </div>
        <div class="container-support-item-desc">
            <strong>Giao hàng miễn phí</strong>
            <p>Các đơn hàng có giá trị từ 200k trở lên</p>
        </div>
    </div>
    <div class="container-support-item">
        <div class="container-support-item-icon">
            <i class="fa-solid fa-right-left"></i>
        </div>
        <div class="container-support-item-desc">
            <strong>Hoàn trả miễn phí</strong>
            <p>Hoàn trả miễn phí trong 9 ngày</p>
        </div>
    </div>
    <div class="container-support-item">
        <div class="container-support-item-icon">
            <i class="fa-solid fa-credit-card"></i>
        </div>
        <div class="container-support-item-desc">
            <strong>Thanh toán an toàn</strong>
            <p>Thanh toán của bạn được an toàn với chúng tôi</p>
        </div>
    </div>
    <div class="container-support-item">
        <div class="container-support-item-icon">
            <i class="fa-solid fa-headset"></i>
        </div>
        <div class="container-support-item-desc">
            <strong>Hỗ trợ 24/7</strong>
            <p>Liên hệ với chúng tôi 24 giờ</p>
        </div>
    </div>
</div>
<!-- //todo container product sales -->
<div class="container-product-sales">
    <div class="container-product-sales-heading">
        <strong>Sản phẩm đang sale</strong>
        <p>Thêm các sản phẩm giảm giá vào hàng tuần</p>
    </div>
    <div class="container-product-sales-slider">
        <?php
        while ($row_pro_sale = mysqli_fetch_array($query_pro_sale)){
        ?>
        <form action="pages/main/addtocart.php?id=<?php echo $row_pro_sale["id_sp"]?>" method="POST">
            <div class=" container-product-sales-item">
                <div class="container-product-sales-img">
                    <img src="admin/modules/quanlysp/uploads/<?php echo $row_pro_sale['hinhanh']?>" alt="">
                </div>
                <div class="product-icon-cart">
                    <ul class="icon-cart-list">
                        <li class="icon-cart-item">
                            <i class="fa-solid fa-heart"></i>
                        </li>
                        <li class="icon-cart-item">
                            <i class="fa-solid fa-magnifying-glass"></i>
                        </li>
                        <li class="icon-cart-item">
                            <i class="fa-solid fa-right-left"></i>
                        </li>
                    </ul>
                </div>
                <p class="product-cate">
                    <?php echo $row_pro_sale['tendanhmuc'] ?>
                </p>
                <a href="index.php?quanly=sanpham&id=<?php echo $row_pro_sale['id_sp'] ?>&iddm=<?php echo $row_pro_sale['id_danhmuc']?>"
                    class="product-title">
                    <?php echo $row_pro_sale['tensp']?>
                </a>
                <?php
                if($row_pro_sale['gia_sale']>0){
                ?>
                <p style="text-decoration: line-through;" class="product-price">
                    <?php echo number_format($row_pro_sale['giasp'],0,',','.'). ' vnđ'?>
                </p>
                <p class="product-price-sales">
                    <?php echo number_format($row_pro_sale['gia_sale'],0,',','.'). ' vnđ'?>
                </p>
                <?php
                }else{
                ?>
                <p class="product-price">
                    <?php echo number_format($row_pro_sale['giasp'],0,',','.'). ' vnđ'?>
                </p>
                <?php
                }
                ?>
                <input type="submit" name="themgiohang" value="Thêm giỏ hàng" class="add-to-cart">
            </div>
        </form>
        <?php
        }
        ?>
    </div>
</div>
<!-- //todo container categories -->
<div class="container-categories">
    <div class="container-categories-heading">
        <strong>Danh mục phổ biến</strong>
        <p>Thêm Danh mục Phổ biến vào hàng tuần</p>
    </div>
    <div class="container-categories-body">
        <div class="container-categories-body-item">
            <strong class="categories-item-title">Burger & Sandwiches</strong><br>
            <a href="index.php?quanly=danhmuc&id=1" class="categories-item-view">
                Xem ngay
                <i class="fa-solid fa-circle-chevron-right"></i>
            </a>
            <img src="./assets/img/BURGER-SANDWICH.jpg" alt="" class="categories-item-img">
        </div>
        <div class="container-categories-body-item">
            <strong class="categories-item-title">Pizza</strong><br>
            <a href="index.php?quanly=danhmuc&id=2" class="categories-item-view">
                Xem ngay
                <i class="fa-solid fa-circle-chevron-right"></i>
            </a>
            <img src="./assets/img/pizza.jpg" alt="" class="categories-item-img">
        </div>
        <div class="container-categories-body-item">
            <strong style="color: white;" class="categories-item-title">Fried Chicken & Nuggets</strong><br>
            <a style="color: white;" href="index.php?quanly=danhmuc&id=3" class="categories-item-view">
                Xem ngay
                <i class="fa-solid fa-circle-chevron-right"></i>
            </a>
            <img src="./assets/img/ChickenNuggets.jpg" alt="" class="categories-item-img">
        </div>
        <div class="container-categories-body-item">
            <strong class="categories-item-title">Drinks & Desserts</strong><br>
            <a href="index.php?quanly=danhmuc&id=4" class="categories-item-view">
                Xem ngay
                <i class="fa-solid fa-circle-chevron-right"></i>
            </a>
            <img src="./assets/img/DrinksDesserts.jpg" alt="" class="categories-item-img">
        </div>
        <div class="container-categories-body-item">
            <strong class="categories-item-title">Combo Meal</strong><br>
            <a href="index.php?quanly=danhmuc&id=5" class="categories-item-view">
                Xem ngay
                <i class="fa-solid fa-circle-chevron-right"></i>
            </a>
            <img src="./assets/img/combomeal.jpg" alt="" class="categories-item-img">
        </div>
    </div>
</div>
<!-- //todo container product iphone  -->
<div class="container-product-iphone">
    <div class="container-product-iphone-heading">
        <strong>Pizza</strong>
        <p>Thêm các sản phẩm vào giỏ hàng ngay</p>
    </div>
    <div class="container-product-iphone-slider">
        <?php
        while ($row_pro_iphone = mysqli_fetch_array($query_pro_iphone)){
        ?>
        <form action="pages/main/addtocart.php?id=<?php echo $row_pro_iphone["id_sp"] ?>" method="POST">
            <div class="container-product-iphone-item">
                <div class="container-product-iphone-img">
                    <img src="admin/modules/quanlysp/uploads/<?php echo $row_pro_iphone['hinhanh'] ?>" alt="">
                </div>
                <div class="product-icon-cart">
                    <ul class="icon-cart-list">
                        <li class="icon-cart-item">
                            <i class="fa-solid fa-heart"></i>
                        </li>
                        <li class="icon-cart-item">
                            <i class="fa-solid fa-magnifying-glass"></i>
                        </li>
                        <li class="icon-cart-item">
                            <i class="fa-solid fa-right-left"></i>
                        </li>
                    </ul>
                </div>
                <p class="product-cate">
                    <?php echo $row_pro_iphone['tendanhmuc'] ?>
                </p>
                <a href="index.php?quanly=sanpham&id=<?php echo $row_pro_iphone['id_sp']?>&iddm=<?php echo $row_pro_iphone['id_danhmuc']?>"
                    class="product-title">
                    <?php echo $row_pro_iphone['tensp'] ?>
                </a>
                <?php
                if($row_pro_iphone['gia_sale']>0){
                ?>
                <p style="text-decoration: line-through;" class="product-price">
                    <?php echo number_format($row_pro_iphone['giasp'],0,',','.'). ' vnđ'?>
                </p>
                <p class="product-price-sales">
                    <?php echo number_format($row_pro_iphone['gia_sale'],0,',','.'). ' vnđ'?>
                </p>
                <?php
                }else{
                ?>
                <p class="product-price">
                    <?php echo number_format($row_pro_iphone['giasp'],0,',','.'). ' vnđ'?>
                </p>
                <?php
                }
                ?>
                <input type="submit" name="themgiohang" value="Thêm giỏ hàng" class="add-to-cart">
            </div>
        </form>
        <?php
        }
        ?>
    </div>
</div>
<!-- //todo container product ipad -->
<div class="container-product-ipad">
    <div class="container-product-ipad-heading">
        <strong>Fried Chicken & Nuggets</strong>
        <p>Thêm các sản phẩm vào giỏ hàng ngay</p>
    </div>
    <div class="container-product-ipad-slider">
        <?php
        while($row_pro_ipad = mysqli_fetch_array($query_pro_ipad)){
        ?>
        <form action="pages/main/addtocart.php?id=<?php echo $row_pro_ipad["id_sp"] ?>" method="POST">
            <div class="container-product-ipad-item">
                <div class="container-product-ipad-img">
                    <img src="admin/modules/quanlysp/uploads/<?php echo $row_pro_ipad['hinhanh']?>" alt="">
                </div>
                <div class="product-icon-cart">
                    <ul class="icon-cart-list">
                        <li class="icon-cart-item">
                            <i class="fa-solid fa-heart"></i>
                        </li>
                        <li class="icon-cart-item">
                            <i class="fa-solid fa-magnifying-glass"></i>
                        </li>
                        <li class="icon-cart-item">
                            <i class="fa-solid fa-right-left"></i>
                        </li>
                    </ul>
                </div>
                <p class="product-cate">
                    <?php echo $row_pro_ipad['tendanhmuc'] ?>
                </p>
                <a href="index.php?quanly=sanpham&id=<?php echo $row_pro_ipad['id_sp'] ?>&iddm=<?php echo $row_pro_ipad['id_danhmuc'] ?>"
                    class="product-title">
                    <?php echo $row_pro_ipad['tensp']?>
                </a>
                <?php
                if($row_pro_ipad['gia_sale']>0){
                ?>
                <p style="text-decoration: line-through;" class="product-price">
                    <?php echo number_format($row_pro_ipad['giasp'],0,',','.'). ' vnđ'?>
                </p>
                <p class="product-price-sales">
                    <?php echo number_format($row_pro_ipad['gia_sale'],0,',','.'). ' vnđ'?>
                </p>
                <?php
                }else{
                ?>
                <p class="product-price">
                    <?php echo number_format($row_pro_ipad['giasp'],0,',','.'). ' vnđ'?>
                </p>
                <?php
                }
                ?>
                <input type="submit" name="themgiohang" value="Thêm giỏ hàng" class="add-to-cart">
            </div>
        </form>
        <?php
        }
        ?>
    </div>
</div>
<!-- //todo grid img -->
<div class="grid-img">
    <div class="grid-img-item">
        <img src="./assets/img/bg.jpg" alt="" class="grid-img-airpod">
    </div>
    <div class="grid-img-item">
        <img src="./assets/img/pz.jpg" alt="" class="grid-img-food">
    </div>
    <div class="grid-img-item">
        <img src="./assets/img/cc.png" alt="" class="grid-img-watch">
    </div>
</div>
<!-- //todo container blog  -->

<!-- //todo grid img footer -->
<div class="grid-img-footer">
    <img src="./assets/img/img-food.jpg" alt="" class="grid-img-footer-bg">
</div>

<div class="go-to-top js-top">
    <a href="#top">
        <i class="fa-solid fa-up-long"></i>
    </a>
</div>