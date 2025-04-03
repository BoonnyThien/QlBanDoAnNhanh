<?php
    $sql_danhmuc = "SELECT * FROM tbl_danhmuc ORDER BY id_danhmuc ASC";
    $query_danhmuc = mysqli_query($mysqli,$sql_danhmuc);
?>
<?php
if (isset($_GET['dangxuat']) && $_GET['dangxuat'] == 1)
   unset($_SESSION['dangky']);
?>
<!-- //todo navmenu -->
<nav class="navmenu js-navmenu">
    <i class="fa-solid fa-bars js-tab-mb"></i>
    <img height="33px" width="74px"  src="./assets/img/logo.jpg" alt="" class="navmenu-logo">
    <div class="navmenu-list js-navmenu-list">
        <i class="fa-solid fa-circle-xmark js-close-list"></i>
        <div class="navmenu-items">
            <a href="index.php" class="navmenu-items-link">Trang chủ</a>
        </div>
        <div class="navmenu-items">
            <a href="index.php?quanly=shop" class="navmenu-items-link">Cửa Hàng</a>
        </div>
        <div class="navmenu-items-dad">
            <a href="#" class="navmenu-items-link">
                Danh Mục
                <i class="fa-solid fa-angle-down"></i>
            </a>
            <ul class="navmenu-items-chill">
                <?php
                while ($row_danhmuc = mysqli_fetch_array($query_danhmuc)) {
                ?>
                <li class="navmenu-item">
                    <a href="index.php?quanly=danhmuc&id=<?php echo $row_danhmuc['id_danhmuc'] ?>"
                        class="navmenu-item-link">
                        <?php echo $row_danhmuc['tendanhmuc'] ?>
                    </a>
                </li>
                <?php
                }
                ?>
            </ul>
        </div>
        <div class="navmenu-items">
            <a href="index.php?quanly=giohang" class="navmenu-items-link">Giỏ Hàng</a>
        </div>
        <div class="navmenu-items">
            <a href="index.php?quanly=lienhe" class="navmenu-items-link">Liên Hệ</a>
        </div>
        <div class="navmenu-items">
            <?php
            if (isset($_SESSION['dangky'])) {
            ?>
            <a class="navmenu-items-link" href="index.php?dangxuat=1">
                Đăng Xuất:
                <?php 
                echo $_SESSION['dangky'];
                ?>
            </a>
            <?php
            } else {
            ?>
            <a class="navmenu-items-link" href="./sign-up.php">Đăng ký</a>
            <?php
            }
            ?>
        </div>
    </div>
    <button class="navmenu-icon-search js-button-search">
        <i class="fa-solid fa-magnifying-glass"></i>
    </button>
    <div class="navmenu-search js-search">
        <form class="form-search" action="index.php?quanly=timkiem" method="POST">
            <input type="text" name="tukhoa" id="search" placeholder="Search...">
            <button class="navmenu-search-icon" name="timkiem">
                <i class="fa-solid fa-magnifying-glass"></i>
            </button>
        </form>
    </div>
    <div class="navmenu-icon">
        <ul class="navmenu-icon-list">
            <li class="navmenu-icon-item">
                <?php
                if(isset($_SESSION['dangky'])){
                ?>
                <a href="index.php?quanly=hoso" class="navmenu-icon-link">
                    <i class="fa-solid fa-user"></i>
                </a>
                <?php
                }else{
                ?>
                <a href="sign-in.php" class="navmenu-icon-link">
                    <i class="fa-solid fa-user"></i>
                </a>
                <?php
                }
                ?>
            </li>
            <li class="navmenu-icon-item">
                <a href="" class="navmenu-icon-link">
                    <i class="fa-solid fa-heart"></i>
                </a>
            </li>
            <li class="navmenu-icon-item">
                <a href="index.php?quanly=giohang" class="navmenu-icon-link">
                    <i class="fa-solid fa-cart-shopping"></i>
                </a>
            </li>
        </ul>
    </div>
</nav>
<script>
const btnTabs = document.querySelector(".js-tab-mb");
const navmenuList = document.querySelector(".js-navmenu-list");
const closeTabs = document.querySelector(".js-close-list")

function showList() {
    navmenuList.classList.add("open");
}

function hideList() {
    navmenuList.classList.remove("open");
}

btnTabs.addEventListener("click", showList);
closeTabs.addEventListener("click", hideList);
</script>