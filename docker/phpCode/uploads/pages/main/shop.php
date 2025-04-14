<?php 
    // Số sản phẩm trên mỗi trang
    $products_per_page = 10;

    // Xác định trang hiện tại
    $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
    $offset = ($page - 1) * $products_per_page;

    // Truy vấn để lấy sản phẩm có phân trang
    $sql_shop = "SELECT * FROM tbl_sanpham, tbl_danhmuc 
                 WHERE tbl_sanpham.id_danhmuc = tbl_danhmuc.id_danhmuc 
                 ORDER BY tbl_sanpham.id_sp ASC 
                 LIMIT $products_per_page OFFSET $offset";
    $query_shop = mysqli_query($mysqli, $sql_shop);

    // Truy vấn để tính tổng số sản phẩm
    $total_products_query = mysqli_query($mysqli, "SELECT COUNT(*) AS total FROM tbl_sanpham");
    $total_products_row = mysqli_fetch_assoc($total_products_query);
    $total_products = $total_products_row['total'];
    $total_pages = ceil($total_products / $products_per_page);
?>
<div class="page-shop">
    <div class="page-shop-heading">
        <img src="././assets/img/banner1.jpg" alt="" class="page-shop-heading-img">
        <div class="page-shop-heading-text">
            <h2>Cửa Hàng</h2>
            <p>Trang chủ > Cửa hàng</p>
        </div>
    </div>
    <div class="page-shop-body row">
        <?php while ($row_shop = mysqli_fetch_array($query_shop)) { ?>
        <form action="pages/main/addtocart.php?id=<?php echo $row_shop['id_sp'] ?>" method="POST">
        <div class="col-xl-3 col-md-4 col-sm6">
            <div class="page-shop-body-products">
                <div class="container-product-sales-img">
                    <img src="admin/modules/quanlysp/uploads/<?php echo $row_shop['hinhanh'] ?>" alt="">
                </div>
                <div class="product-icon-cart">
                    <ul class="icon-cart-list">
                        <li class="icon-cart-item"><i class="fa-solid fa-heart"></i></li>
                        <li class="icon-cart-item"><i class="fa-solid fa-magnifying-glass"></i></li>
                        <li class="icon-cart-item"><i class="fa-solid fa-right-left"></i></li>
                    </ul>
                </div>
                <p class="product-cate"><?php echo $row_shop['tendanhmuc'] ?></p>
                <a href="index.php?quanly=sanpham&id=<?php echo $row_shop['id_sp'] ?>&iddm=<?php echo $row_shop['id_danhmuc'] ?>" class="product-title"><?php echo $row_shop['tensp'] ?></a>
                <?php if($row_shop['gia_sale'] > 0) { ?>
                <p style="text-decoration:line-through;" class="product-price"><?php echo number_format($row_shop['giasp'], 0, '.', '.') . " vnđ" ?></p>
                <p class="product-price-sales"><?php echo number_format($row_shop['gia_sale'], 0, '.', '.') . " vnđ" ?></p>
                <?php } else { ?>
                <p class="product-price"><?php echo number_format($row_shop['giasp'], 0, '.', '.') . " vnđ" ?></p>
                <?php } ?>
                <input type="submit" name="themgiohang" value="Thêm giỏ hàng" class="add-to-cart">
            </div>
        </div>
        </form>
        <?php } ?>
    </div>

    <div class="pagination">
    <?php for($i = 1; $i <= $total_pages; $i++) { ?>
        <a href="index.php?quanly=shop&page=<?php echo $i ?>" class="pagination-link <?php echo $i == $page ? 'active' : '' ?>">
            <?php echo $i ?>
        </a>
    <?php } ?>
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
