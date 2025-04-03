<?php
    $sql_pro_cate = "SELECT * FROM tbl_sanpham WHERE tbl_sanpham.id_danhmuc = '$_GET[id]' ORDER BY id_sp ASC";
    $query_pro_cate = mysqli_query($mysqli,$sql_pro_cate);
?>
<?php
    $sql_cate = "SELECT * FROM tbl_danhmuc WHERE tbl_danhmuc.id_danhmuc='$_GET[id]'";
    $query_cate = mysqli_query($mysqli,$sql_cate);
?>
<?php
    $sql_sidebar = "SELECT * FROM tbl_danhmuc ORDER BY id_danhmuc ASC";
    $query_sidebar = mysqli_query($mysqli,$sql_sidebar);
?>
<div class="page-categories">
    <div class="page-categories-heading">
        <img src="././assets/img/QC.jpg" alt="" class="page-categories-heading-img">
        <?php 
            while($row_cate = mysqli_fetch_array($query_cate)){
        ?>
        <div class="page-categories-heading-text">
            <h2 style="color: orange;border:1px black; ">Danh Mục</h2>
            <p style="color: orange; border:1px black;">Trang chủ > <?php echo $row_cate['tendanhmuc'] ?></p>
        </div>
        <?php
        }
        ?>
    </div>
    <div class="page-categories-body">
        <div class="page-categories-body-sidebar">
            <p>Danh mục sản phẩm</p>
            <ul class="page-categories-body-sidebar-list">
                <?php
                while($row_sidebar = mysqli_fetch_array($query_sidebar)){
                ?>
                <li class="page-categories-item">
                    <a href="index.php?quanly=danhmuc&id=<?php echo $row_sidebar['id_danhmuc']?>"
                        class="page-categories-link">
                        <?php echo $row_sidebar['tendanhmuc']?>
                    </a>
                </li>
                <?php
                }
                ?>
            </ul>
        </div>
        <div class="page-categories-body-product">
            <?php
                while ($row_pro_cate = mysqli_fetch_array($query_pro_cate)){
            ?>
            <form class="page-categories-body-product-item" action="pages/main/addtocart.php?id=<?php echo $row_pro_cate['id_sp'] ?>" method="POST">
                <div class="container-product-sales-img">
                    <img src="admin/modules/quanlysp/uploads/<?php echo $row_pro_cate['hinhanh'] ?>" alt="">
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
                <a href="index.php?quanly=sanpham&id=<?php echo $row_pro_cate['id_sp'] ?>&iddm=<?php echo $row_pro_cate['id_danhmuc'] ?>"
                    class="product-title">
                    <?php echo $row_pro_cate['tensp'] ?>
                </a>
                <?php
                    if($row_pro_cate['gia_sale']>0){
                ?>
                <p style="text-decoration: line-through;" class="product-price">
                    <?php echo number_format($row_pro_cate['giasp'],0,'.','.').' vnđ' ?>
                </p>
                <p class="product-price-sales">
                    <?php echo  number_format($row_pro_cate['gia_sale'],0,'.','.')." vnđ" ?>
                </p>
                <?php
                    }else{
                ?>
                <p class="product-price">
                    <?php echo number_format($row_pro_cate['giasp'],0,'.','.').' vnđ' ?>
                </p>
                <?php
                    }
                ?>
                <input type="submit" name="themgiohang" value="Thêm giỏ hàng" class="add-to-cart">
            </form>
            <?php
            }
            ?>
        </div>
    </div>
</div>
<div class="go-to-top js-top">
    <a href="#top">
        <i class="fa-solid fa-up-long"></i>
    </a>
</div>
<script>
window.addEventListener("scroll", function() {
    var goTop = document.querySelector(".js-top");
    goTop.classList.toggle("open", window.scrollY > 0);
});
</script>