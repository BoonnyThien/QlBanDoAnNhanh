<div class="content-wrapper" style="min-height: 359px; background-color: #fff;">
    <?php
   if (isset($_GET['action']) && $_GET['query']) {
      $tam = $_GET['action'];
      $query = $_GET['query'];
   } else {
      $tam = '';
      $query = '';
   }
   if ($tam == 'quanlydanhmucsanpham' && $query == 'them') {
      include("modules/quanlydanhmuc/them.php");
   } 
   else if ($tam == 'quanlydanhmucsanpham' && $query == 'lietke') {
      include("modules/quanlydanhmuc/lienke.php");
   }
   elseif ($tam == 'quanlydanhmucsanpham' && $query == 'sua') {
      include("modules/quanlydanhmuc/sua.php");
   } 
   elseif ($tam == 'quanlysp' && $query == 'them') {
      include("modules/quanlysp/them.php");
   } 
   elseif ($tam == 'quanlysp' && $query == 'lietke'){
      include("modules/quanlysp/lienke.php");
   }
   elseif ($tam == 'quanlysp' && $query == 'sua') {
      include("modules/quanlysp/sua.php");
   } 
   elseif ($tam == 'quanlydonhangddk' && $query == 'lietke') {
      include("modules/quanlydonhang/lietke-registered.php");
   } 
   elseif ($tam == 'quanlydonhangcdk' && $query == 'lietke') {
      include("modules/quanlydonhang/lietke-unregistered.php");
   }
   elseif ($tam == 'donhang' && $query == 'xemdonhang') {
      include("modules/quanlydonhang/xemdonhang.php");
   } 
   elseif ($tam == 'quanlybaiviet' && $query == 'them') {
         include("modules/quanlybaiviet/them.php");
   } 
   elseif ($tam == 'quanlybaiviet' && $query == 'sua') {
      include("modules/quanlybaiviet/sua.php");
   } 
   elseif ($tam == 'quanlybaiviet' && $query == 'lietke') {
      include("modules/quanlybaiviet/lietke.php");
   }
   elseif ($tam == 'taikhoannguoidung' && $query == 'lietke') {
      include("modules/quanlytaikhoan/lietkekhachhang.php");
   }
   elseif ($tam == 'quanlycmt' && $query == 'lietke') {
      include("modules/quanlycmt/lietke.php");
   }
   elseif ($tam == 'phanhoi' && $query == 'lietke') {
      include("modules/phanhoi/lietke.php");
   }
   elseif ($tam == 'add' && $query == 'them') {
      include("modules/themadmin/addadmin.php");
   }
   else {
      include("modules/dashboard.php");
   }
   ?>
</div>