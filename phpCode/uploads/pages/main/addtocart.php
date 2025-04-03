<?php
	ob_start();
	session_start();
	include('../../admin/config/config.php');
	// them so luong
	if(isset($_GET['cong'])){
		$id = $_GET['cong'];
		foreach($_SESSION['cart'] as $cart_item){
			if($cart_item['id'] != $id){
				$product[] = array('tensp'=>$cart_item['tensp'],'id'=>$cart_item['id'],'soluong'=>$cart_item['soluong'],'giasp'=>$cart_item['giasp'],'gia_sale'=>$cart_item['gia_sale'],'hinhanh'=>$cart_item['hinhanh'],'masp'=>$cart_item['masp']);
				$_SESSION['cart'] = $product;
			}else{
				$tangsoluong = $cart_item['soluong'] + 1;
				if($cart_item['soluong']<=9){
					$product[] = array('tensp'=>$cart_item['tensp'],'id'=>$cart_item['id'],'soluong'=>$tangsoluong,'giasp'=>$cart_item['giasp'],'gia_sale'=>$cart_item['gia_sale'],'hinhanh'=>$cart_item['hinhanh'],'masp'=>$cart_item['masp']);
				}else{
					$product[] = array('tensp'=>$cart_item['tensp'],'id'=>$cart_item['id'],'soluong'=>$cart_item['soluong'],'giasp'=>$cart_item['giasp'],'gia_sale'=>$cart_item['gia_sale'],'hinhanh'=>$cart_item['hinhanh'],'masp'=>$cart_item['masp']);
				}
				$_SESSION['cart'] = $product;
			}
		}
		header('Location:../../index.php?quanly=giohang');	
	}
	//tru so luong
	if(isset($_GET['tru'])){
		$id = $_GET['tru'];
		foreach($_SESSION['cart'] as $cart_item){
			if($cart_item['id'] != $id){
				$product[] = array('tensp'=>$cart_item['tensp'],'id'=>$cart_item['id'],'soluong'=>$cart_item['soluong'],'giasp'=>$cart_item['giasp'],'gia_sale'=>$cart_item['gia_sale'],'hinhanh'=>$cart_item['hinhanh'],'masp'=>$cart_item['masp']);
				$_SESSION['cart'] = $product;
			}else{
				$tangsoluong = $cart_item['soluong'] - 1;
				if($cart_item['soluong']>1){
					$product[] = array('tensp'=>$cart_item['tensp'],'id'=>$cart_item['id'],'soluong'=>$tangsoluong,'giasp'=>$cart_item['giasp'],'gia_sale'=>$cart_item['gia_sale'],'hinhanh'=>$cart_item['hinhanh'],'masp'=>$cart_item['masp']);
				}else{
					$product[] = array('tensp'=>$cart_item['tensp'],'id'=>$cart_item['id'],'soluong'=>$cart_item['soluong'],'giasp'=>$cart_item['giasp'],'gia_sale'=>$cart_item['gia_sale'],'hinhanh'=>$cart_item['hinhanh'],'masp'=>$cart_item['masp']);
				}
				$_SESSION['cart'] = $product;
			}
		}
		header('Location:../../index.php?quanly=giohang');	
	}
	//xoa sam pham
	if(isset($_SESSION['cart'])&&isset($_GET['xoa'])){
		$id=$_GET['xoa'];
		foreach($_SESSION['cart'] as $cart_item){
			//khi cart_item['id'] != id thì sẽ chạy lại hết bỏ lại cái(=id) 
			if($cart_item['id'] != $id){
				$product[] = array('tensp'=>$cart_item['tensp'],'id'=>$cart_item['id'],'soluong'=>$cart_item['soluong'],'giasp'=>$cart_item['giasp'],'gia_sale'=>$cart_item['gia_sale'],'hinhanh'=>$cart_item['hinhanh'],'masp'=>$cart_item['masp']);

			}
		// tạo session mới lưu lại những cái != id
		$_SESSION['cart'] = $product;
		header('Location:../../index.php?quanly=giohang');
		}
	}
	//xoa tat ca
	if(isset($_GET['xoatatca'])&&$_GET['xoatatca']==1){
		unset($_SESSION['cart']);
		header('Location:../../index.php?quanly=giohang');
	}
	// them san pham vao gio hang
	if(isset($_POST['themgiohang'])){
		//session_destroy();
		$id = $_GET['id'];
		$soluong=1;
		$sql = "SELECT * FROM tbl_sanpham WHERE id_sp ='".$id."' LIMIT 1";
		$query = mysqli_query($mysqli,$sql);
		$row = mysqli_fetch_array($query);
		if($row){
			$new_product=array(array('tensp'=>$row['tensp'],'id'=>$id,'soluong'=>$soluong,'giasp'=>$row['giasp'],'gia_sale'=>$row['gia_sale'],'hinhanh'=>$row['hinhanh'],'masp'=>$row['masp']));
			//kiem tra session gio hang ton tai
			if(isset($_SESSION['cart'])){	
				$found = false;
				foreach ($_SESSION['cart'] as $cart_item) {
					//neu du lieu trung
					if($cart_item['id'] == $id){
						$product[] = array('tensp'=>$cart_item['tensp'],'id'=>$cart_item['id'],'soluong'=>$soluong+1,'giasp'=>$cart_item['giasp'],'gia_sale'=>$cart_item['gia_sale'],'hinhanh'=>$cart_item['hinhanh'],'masp'=>$cart_item['masp']);
						$found = true;
					}else{
						//neu du lieu khong trung
						$product[] = array('tensp'=>$cart_item['tensp'],'id'=>$cart_item['id'],'soluong'=>$cart_item['soluong'],'giasp'=>$cart_item['giasp'],'gia_sale'=>$cart_item['gia_sale'],'hinhanh'=>$cart_item['hinhanh'],'masp'=>$cart_item['masp']);
					}
				}
				if($found == false){
					//lien ket du lieu new_product vs product
					$_SESSION['cart']=array_merge($product,$new_product);
				}else{
					$_SESSION['cart']=$product;
				}
			}else{
				$_SESSION['cart'] = $new_product;
			}

		}
		header('Location:../../index.php?quanly=giohang');
	}
?>