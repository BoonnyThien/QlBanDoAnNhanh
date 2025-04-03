<?php
$sql_post = "SELECT * FROM tbl_baiviet ORDER BY id_baiviet DESC";
$query_post = mysqli_query($mysqli, $sql_post)
?>
<?php
$sql_post_tt = "SELECT * FROM tbl_baiviet ORDER BY id_baiviet DESC";
$query_post_tt = mysqli_query($mysqli, $sql_post)
?>
<div class="page-post">
    <div class="page-post-heading">
        <img src="././assets/img/banner-post.png" alt="" class="page-post-heading-img">
        <div class="page-post-heading-text">
            <h2>Bài Viết</h2>
            <p>Trang chủ > Bài viết</p>
        </div>
    </div>
    <div class="page-post-body">
        <div class="page-post-body-left">
            <?php
            while ($row_post = mysqli_fetch_array($query_post)){
            ?>
            <a href="#" class="page-post-body-left-item">
                <img src="admin/modules/quanlybaiviet/img_post/<?php echo $row_post['img_baiviet'] ?>" alt=""
                    class="page-post-body-left-item-img">
                <div class="page-post-body-left-item-desc">
                    <p class="page-post-body-left-item-desc-title">
                        <?php echo $row_post['tieude'] ?>
                    </p>
                    <p class="page-post-body-left-item-desc-content">
                        <?php echo $row_post['tomtat'] ?>
                    </p>
                    <p class="page-post-body-left-item-desc-user">Dino</p>
                    <p class="page-post-body-left-item-desc-date">
                        <?php echo $row_post['ngayviet'] ?>
                    </p>
                </div>
            </a>
            <?php
            }
            ?>
        </div>
        <div class="page-post-body-right">
            <?php
            while($row_post_tt = mysqli_fetch_array($query_post_tt)){
            ?>
            <div class="page-post-body-right-item">
                <img src="admin/modules/quanlybaiviet/img_post/<?php echo $row_post_tt['img_baiviet'] ?>" alt=""
                    class="page-post-body-right-item-img">
                <div class="page-post-body-right-item-desc">
                    <a href="#" class="page-post-body-right-item-desc-title">
                        <?php echo $row_post_tt['tieude'] ?>
                    </a>
                    <p class="page-post-body-right-item-desc-user">Dino</p>
                </div>
            </div>
            <?php
            }
            ?>
        </div>
    </div>
</div>