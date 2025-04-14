-- Không tạo lại user nếu đã có
CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED BY 'userpass';

-- Gán quyền cho user app_user
GRANT ALL PRIVILEGES ON qlbandoannhanh.* TO 'app_user'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- Tạo cơ sở dữ liệu với mã hóa UTF-8 để hỗ trợ tiếng Việt
CREATE DATABASE IF NOT EXISTS qlbandoannhanh 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Sử dụng cơ sở dữ liệu
USE qlbandoannhanh;

-- Kiểm tra quyền của user (tùy chọn, để debug)
SHOW GRANTS FOR 'app_user'@'%';

CREATE TABLE `tbl_admin` (
  `id_admin` int(11) NOT NULL,
  `nameadmin` varchar(200) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `admin_status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_admin`
--

INSERT INTO `tbl_admin` (`id_admin`, `nameadmin`, `username`, `password`, `admin_status`) VALUES
(1, 'Nguyễn Huy Hoàng', 'dino', '25f9e794323b453885f5181f1b624d0b', 1),
(2, 'Thái Văn Hà', 'vanha', '25f9e794323b453885f5181f1b624d0b', 1),
(3, 'Đặng Phương Dung', 'pdung', '25f9e794323b453885f5181f1b624d0b', 1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_baiviet`
--

CREATE TABLE `tbl_baiviet` (
  `id_baiviet` int(11) NOT NULL,
  `tieude` varchar(250) NOT NULL,
  `img_baiviet` varchar(100) NOT NULL,
  `tomtat` tinytext NOT NULL,
  `noidung` longtext NOT NULL,
  `ngayviet` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_cart_details`
--

CREATE TABLE `tbl_cart_details` (
  `id_cart_details` int(11) NOT NULL,
  `code_cart` varchar(20) NOT NULL,
  `id_sp` int(11) NOT NULL,
  `soluongmua` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_cart_details`
--

INSERT INTO `tbl_cart_details` (`id_cart_details`, `code_cart`, `id_sp`, `soluongmua`) VALUES
(1, '2366', 1, 1),
(2, '7877', 2, 1),
(3, '8851', 3, 1),
(4, '8851', 1, 1),
(5, '3959', 2, 2),
(6, '3959', 1, 1),
(7, '6223', 2, 1),
(8, '6375', 3, 1),
(9, '4459', 4, 1),
(10, '9665', 2, 1),
(11, '2477', 19, 1),
(12, '4749', 9, 1),
(13, '7138', 1, 1),
(14, '4515', 1, 1),
(15, '2520', 1, 1),
(16, '1610', 9, 1),
(17, '7777', 3, 1),
(18, '59', 4, 1),
(19, '3011', 2, 1),
(20, '3011', 3, 1),
(21, '3011', 12, 1),
(22, '4481', 9, 1),
(23, '4481', 10, 1),
(24, '4481', 11, 1),
(25, '6933', 20, 1),
(26, '6933', 23, 1),
(27, '3809', 4, 1),
(28, '6219', 2, 1),
(29, '8610', 1, 1),
(30, '3333', 2, 1),
(31, '3333', 3, 1),
(32, '3333', 11, 1),
(33, '1853', 38, 2),
(34, '1853', 22, 1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_cart_registered`
--

CREATE TABLE `tbl_cart_registered` (
  `id_cart_registered` int(11) NOT NULL,
  `id_khachhang` int(11) NOT NULL,
  `code_cart` varchar(20) NOT NULL,
  `cart_status` int(11) NOT NULL,
  `cart_date` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_cart_registered`
--

INSERT INTO `tbl_cart_registered` (`id_cart_registered`, `id_khachhang`, `code_cart`, `cart_status`, `cart_date`) VALUES
(7, 4, '2366', 0, ''),
(9, 5, '7877', 0, ''),
(12, 8, '6223', 0, '2021-12-05 09:53:22'),
(13, 8, '6375', 0, '2021-12-05 09:53:58'),
(18, 9, '2477', 0, '2021-12-07 07:58:44'),
(19, 9, '4749', 0, '2021-12-07 08:02:32'),
(20, 9, '7138', 0, '2021-12-07 08:11:12'),
(21, 9, '4515', 0, '2021-12-07 08:16:10'),
(22, 9, '2520', 0, '2021-12-07 08:17:13'),
(23, 10, '3011', 0, '2021-12-15'),
(24, 10, '4481', 0, '2021-12-15'),
(25, 10, '6933', 0, '2021-12-15');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_cart_unregistered`
--

CREATE TABLE `tbl_cart_unregistered` (
  `id_cart_unregistered` int(11) NOT NULL,
  `tenkh` varchar(250) NOT NULL,
  `diachi` varchar(250) NOT NULL,
  `sdt` varchar(20) NOT NULL,
  `email` varchar(250) NOT NULL,
  `noidung` longtext NOT NULL,
  `code_cart` varchar(10) NOT NULL,
  `cart_status` int(11) NOT NULL,
  `cart_date` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_cart_unregistered`
--

INSERT INTO `tbl_cart_unregistered` (`id_cart_unregistered`, `tenkh`, `diachi`, `sdt`, `email`, `noidung`, `code_cart`, `cart_status`, `cart_date`) VALUES
(5, 'Thái Văn Hà', 'Nghệ An', '01564578978', 'hadz@gmail.com', 'ship nhanh nha shop', '3959', 0, ''),
(6, 'ha', 'HN', '0372216266', 'dino@gmail.com', 'wfhoiwdf', '9292', 0, '2021-12-05 09:58:12'),
(7, 'ha', 'HN', '0372216266', 'dino@gmail.com', 'wfhoiwdf', '9984', 0, '2021-12-05 09:59:37'),
(8, 'ha', 'HN', '0372216266', 'dino@gmail.com', 'wfhoiwdf', '2187', 0, '2021-12-05 09:59:41'),
(9, 'ha', 'HN', '0372216266', 'dino@gmail.com', 'wfhoiwdf', '5968', 0, '2021-12-05 10:00:40'),
(10, 'ha', 'HN', '0372216266', 'dino@gmail.com', 'wfhoiwdf', '9150', 0, '2021-12-05 10:00:43'),
(11, 'Thái Văn Hà ', 'NA', '0372216266', 'thaivanha739@gmail.com', 'xcgjgj', '4459', 0, '2021-12-05 10:01:14'),
(12, 'Thái Văn Hà ', 'NA', '0372216266', 'thaivanha739@gmail.com', 'xcgjgj', '6524', 0, '2021-12-05 10:04:58'),
(13, 'Thái Văn Hà ', 'DL', '0372216266', 'dino@gmail.com', 'hahahahah', '9665', 0, '2021-12-07 07:53:29'),
(14, 'Thái Văn Hà ', 'NA', '0372216266', 'thaivanha739@gmail.com', 'sioufgbws', '1610', 0, '2021-12-07 08:22:10'),
(15, 'Thái Văn Hà ', 'NA', '0372216266', 'thaivanha739@gmail.com', 'sioufgbws', '9964', 0, '2021-12-07 08:22:39'),
(16, 'fsfsdf', 'sdfsdfdsf', 'fsdf', 'sdfsdfdsf', 'sdfsdfdsfsd', '7777', 0, '2021-12-15'),
(17, 'Đặng Phương Dung', 'NA', '0213544684', 'pdung@gmail.com', 'ship nhanh nha shop', '59', 0, '2021-12-15'),
(18, 'tesst', 'test', 'test', 'test', 'test
Dòng thứ hai
Dòng thứ ba', '3809', 0, '2021-12-15'),
(19, 'test', 'test', 'test', 'test', 'ship nhanh nhé shop', '6219', 0, '2021-12-16'),
(20, 'tesst', 'tesst', 'test', 'tesst', '', '8610', 0, '2021-12-16'),
(21, 'Lưu Công Lộc', 'Nam Định', '02464126545', 'locluu@gmail.com', 'Ship nhanh nhé shop', '3333', 0, '2021-12-18'),
(22, 'test11', 'qn', '012424141', 'gj@gmail.com', 'Nhanh cần ăn gấp', '1853', 1, '2024-10-30');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_comments`
--

CREATE TABLE `tbl_comments` (
  `id_cmt` int(11) NOT NULL,
  `name` varchar(250) NOT NULL,
  `name_email` varchar(250) NOT NULL,
  `noidung` longtext NOT NULL,
  `id_sp` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_comments`
--

INSERT INTO `tbl_comments` (`id_cmt`, `name`, `name_email`, `noidung`, `id_sp`) VALUES
(2, 'Dino', 'dino@gmail.com', 'Hàng rất là ngon nha Shop. Ship hàng nhanh gọn', 2),
(3, 'Văn Hà', 'hangu@gmail.com', 'Sản phẩm rất tốt', 1),
(5, 'locdz', 'locdz@gmail.com', 'hàng rất tốt', 2),
(6, 'binhdz', 'binhdz@gmail.com', 'hàng ship nhanh', 2),
(7, 'Hà dz', 'hadz@gmail.com', 'sản phẩm rất tốt nha shop <3', 1),
(11, 'huy', 'huy@gmail.com', 'hàng tuyệt vời', 1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_dangky`
--

CREATE TABLE `tbl_dangky` (
  `id_khachhang` int(11) NOT NULL,
  `tenkhachhang` varchar(250) NOT NULL,
  `email` varchar(100) NOT NULL,
  `diachi` varchar(250) NOT NULL,
  `matkhau` varchar(250) NOT NULL,
  `dienthoai` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_dangky`
--

INSERT INTO `tbl_dangky` (`id_khachhang`, `tenkhachhang`, `email`, `diachi`, `matkhau`, `dienthoai`) VALUES
(3, 'Huy Hoàng', 'hoang@gmail.com', 'Hải Dương', 'e10adc3949ba59abbe56e057f20f883e', '0867699706'),
(4, 'Dino', 'huy43412@gmail.com', 'Hải Dương', 'e10adc3949ba59abbe56e057f20f883e', '0867699706'),
(5, 'Lưu Công Lộc', 'locdz@gmail.com', 'Nam Định', 'e10adc3949ba59abbe56e057f20f883e', '0154568789'),
(7, 'Van ha', 'vanha1@gmail.com', 'NA', 'e10adc3949ba59abbe56e057f20f883e', '0372216266'),
(8, 'ha van', 'vanha2@gmail.com', 'HN', 'e10adc3949ba59abbe56e057f20f883e', '0372216266'),
(9, 'Thái Văn Hà', 'vanha6@gmail.com', 'TS', 'e10adc3949ba59abbe56e057f20f883e', '0372216266'),
(10, 'Đặng Phương Dung', 'pdung@gmail.com', 'NA', 'e10adc3949ba59abbe56e057f20f883e', '04542215465'),
(11, 'test', 'test@gmail.com', 'test', 'e10adc3949ba59abbe56e057f20f883e', 'test'),
(12, 'ssss', 'hoang@gmail.com', '123', '202cb962ac59075b964b07152d234b70', '1234'),
(13, 'Nguyễn Vũ Hiệp', 'ad@gmail.com', 'Quảng Ninh', 'e10adc3949ba59abbe56e057f20f883e', '0789388656'),
(14, 'admin', 'admin@gmail.com', 'QN', '21232f297a57a5a743894a0e4a801fc3', '195713985'),
(15, 'thai anh', 'thaianh@gmail.com', 'Ha Noii', 'e10adc3949ba59abbe56e057f20f883e', '12323');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_danhmuc`
--

CREATE TABLE `tbl_danhmuc` (
  `id_danhmuc` int(11) NOT NULL,
  `tendanhmuc` varchar(200) NOT NULL,
  `thutu` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_danhmuc`
--

INSERT INTO `tbl_danhmuc` (`id_danhmuc`, `tendanhmuc`, `thutu`) VALUES
(1, 'Burger & Sandwiches', 1),
(2, 'Pizza', 2),
(3, 'Fried Chicken & Nuggets', 3),
(4, 'Drinks & Desserts', 4),
(5, 'Combo Meal', 5);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_phanhoi`
--

CREATE TABLE `tbl_phanhoi` (
  `id_ph` int(11) NOT NULL,
  `hoten` varchar(200) NOT NULL,
  `email` varchar(200) NOT NULL,
  `noidung` longtext NOT NULL,
  `status` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_phanhoi`
--

INSERT INTO `tbl_phanhoi` (`id_ph`, `hoten`, `email`, `noidung`, `status`) VALUES
(2, 'test', 'test@gmail.com', 'test', 0),
(3, 'test', 'test@gmail.com', 'test', 0),
(4, 'test', 'test@gmail.com', 'test', 0),
(5, 'hello', 'hello@gmail.com', 'hello', 0),
(6, 'test', 'test@gmail.com', 'test', 0),
(7, 'Hiep', 'a@gmail.com', 'Đồ ăn ngon', 0),
(8, 'test0001', 'a@gmail.com', 'do an ngon', 1),
(9, 'Hiep1111', 'a@gmail.com', 'Ngon ', 1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_sanpham`
--

CREATE TABLE `tbl_sanpham` (
  `id_sp` int(11) NOT NULL,
  `tensp` varchar(1200) NOT NULL,
  `masp` varchar(50) NOT NULL,
  `giasp` varchar(100) NOT NULL,
  `gia_sale` varchar(100) NOT NULL,
  `hinhanh` varchar(100) NOT NULL,
  `mota` varchar(1000) NOT NULL,
  `tinhtrang` int(11) NOT NULL,
  `id_danhmuc` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_sanpham`
--

INSERT INTO `tbl_sanpham` (`id_sp`, `tensp`, `masp`, `giasp`, `gia_sale`, `hinhanh`, `mota`, `tinhtrang`, `id_danhmuc`) VALUES
(1, 'Pulled Pork Sandwich', 'sw01', '3000', '2000', '1730278747_sw3.jpg', 'Pulled Pork Sandwich\\r\\nSandwich thịt heo xé nhỏ phủ sốt BBQ ngọt nhẹ, kèm với bắp cải trộn giòn, tạo nên hương vị đậm đà, thích hợp cho bữa ăn nhanh giàu protein.', 1, 1),
(2, 'Pizza Thịt Nguội & Dứa', 'pz01', '7000', '0', '1730278684_pizza3.jpg', 'Pizza Thịt Nguội & Dứa\\r\\nPizza nhiệt đới với thịt nguội mặn mà, kết hợp cùng vị ngọt thanh của dứa và phô mai mozzarella, đem lại sự hài hòa giữa vị ngọt và mặn rất hấp dẫn.', 1, 2),
(3, 'Veggie Delight Burger', 'bg02', '2500', '2000', '1730278648_pizza5.jpg', 'Veggie Delight Burger\\r\\nBurger chay với bánh patty làm từ đậu và rau củ, phủ thêm phô mai và rau xanh, thích hợp cho người ăn chay nhưng vẫn đầy hương vị.', 1, 2),
(4, 'Fish Fillet Sandwich', 'sw03', '5000', '3000', '1730278602_sw2.jpg', 'Fish Fillet Sandwich\\r\\nMiếng cá chiên giòn với sốt tartar chua ngọt, xà lách tươi và phô mai, đem lại cảm giác nhẹ nhàng nhưng vẫn đầy đủ vị ngon từ cá.', 1, 1),
(5, 'Chicken Caesar Sandwich', 'sw04', '3000', '0', '1730278559_sw1.jpg', 'Chicken Caesar Sandwich\\r\\nBánh mì sandwich gà nướng với rau xà lách giòn và sốt Caesar béo ngậy, giúp làm mới khẩu vị với sự kết hợp giữa vị gà nướng và vị sốt thanh nhẹ.', 1, 1),
(7, 'Mushroom Swiss Burger', 'bg05', '3000', '0', '1730278507_bg5.jpg', 'Mushroom Swiss Burger\\r\\nThịt bò nướng kèm nấm xào thơm lừng và phô mai Thụy Sĩ, tạo ra một chiếc burger đậm vị, thơm ngậy với chút vị ngọt tự nhiên từ nấm.', 1, 1),
(8, 'BBQ Bacon Burger', 'bg06', '5000', '3000', '1730278469_bg4.jpg', 'BBQ Bacon Burger\\r\\nBánh burger thịt bò nướng sốt BBQ, thịt xông khói giòn tan, phô mai cheddar và hành tây caramen, tạo nên sự kết hợp giữa vị ngọt, mặn và khói thơm đặc trưng.', 1, 1),
(9, 'Spicy Chicken Burger', 'bg07', '1000', '0', '1730278431_bg3.jpg', 'Spicy Chicken Burger\\r\\nGà rán cay giòn rụm, kết hợp cùng phô mai, rau xà lách và sốt cay đặc biệt, tạo nên sự bùng nổ vị giác với độ cay và giòn ngon không thể cưỡng lại.', 1, 1),
(10, 'Cheese Lover’s Burger', 'bg08', '400', '0', '1730278387_bg2.jpg', 'Cheese Lover’s Burger\\r\\nBurger phô mai với hai lớp phô mai cheddar tan chảy, thịt bò nướng mềm, kèm sốt phô mai béo ngậy, dành riêng cho những ai yêu thích vị phô mai đậm đà.', 1, 1),
(11, 'Classic Beef Burger', 'bg09', '2000', '0', '1730278340_bg1.jpg', 'Classic Beef Burger\\r\\nBánh burger bò truyền thống với miếng thịt bò nướng thơm lừng, phô mai cheddar, xà lách, cà chua và dưa leo muối, tạo nên vị đậm đà và hài hòa trong từng miếng cắn.', 1, 1),
(12, 'Pizza Thập Cẩm', 'pz03', '3000', '0', '1730278264_pizza6.jpg', 'Pizza Thập Cẩm\\r\\nPizza thập cẩm đầy ắp các loại nhân như pepperoni, xúc xích, thịt nguội, ớt chuông, và nấm, giúp bạn tận hưởng nhiều hương vị trong cùng một miếng bánh.', 1, 2),
(13, 'Pizza Gà Nướng Teriyaki', 'pz04', '2000', '0', '1730278221_pizza5.jpg', 'Pizza Gà Nướng Teriyaki\\r\\nGà nướng sốt teriyaki phủ trên nền pizza giòn, kết hợp cùng nấm, hành lá và phô mai mozzarella, mang đến hương vị Nhật Bản độc đáo và thơm ngon.', 1, 2),
(14, 'Pizza Bò Nướng BBQ', 'pz05', '700', '0', '1730278166_pizza4.jpg', 'Pizza Bò Nướng BBQ\\r\\nThịt bò nướng BBQ đậm vị phủ đều trên nền sốt BBQ, thêm chút hành tây và ớt chuông, tạo sự hòa quyện tuyệt vời giữa vị mặn, ngọt và chút cay nồng.', 1, 2),
(15, 'Pizza Xúc Xích & Thịt Xông Khói', 'pz06', '700', '400', '1730278123_pizza3.jpg', 'Pizza Xúc Xích & Thịt Xông Khói\\r\\nPhần pizza đầy đặn với xúc xích cay, thịt xông khói, và hành tây, hòa quyện cùng phô mai mozzarella tan chảy, tạo nên hương vị đậm đà và hấp dẫn.', 1, 2),
(16, 'Pizza Hải Sản', 'pz07', '5000', '0', '1730278084_pizza2.jpg', 'Pizza Hải Sản\\r\\nPizza hải sản đầy đặn với tôm, mực, nghêu, kết hợp cùng sốt kem và phô mai mozzarella, đem đến cảm giác tươi mới và ngọt ngào của biển cả.', 1, 2),
(17, 'Pizza Phô Mai Bốn Lớp', 'pz08', '3000', '0', '1730278026_pizza1.jpg', 'Pizza Phô Mai Bốn Lớp\\r\\nPizza với bốn loại phô mai béo ngậy (mozzarella, cheddar, parmesan và phô mai xanh) tan chảy trên nền đế giòn, tạo nên hương vị đậm đà, thơm phức.', 1, 2),
(18, 'Cánh Gà Rán BBQ', 'gr08', '2000', '0', '1730277855_canhgabbq.jpg', 'Cánh Gà Rán BBQ\\r\\nCánh gà rán phủ sốt BBQ cay nồng và ngọt ngào, kết hợp giữa lớp vỏ giòn tan và sốt BBQ đậm vị, là lựa chọn hoàn hảo cho những ai yêu thích vị BBQ đặc trưng.', 1, 3),
(19, 'Gà Rán Tẩm Sốt Tỏi', 'gr02', '700', '0', '1730277812_gasottoi.jpg', 'Gà Rán Tẩm Sốt Tỏi\\r\\nMiếng gà rán tẩm sốt tỏi đậm đà, thơm nức với hương tỏi hòa quyện cùng gia vị mặn ngọt, tạo nên hương vị độc đáo và lạ miệng.', 1, 3),
(20, 'Gà Không Xương Tẩm Bột', 'gr03', '700', '0', '1730277748_gatambot.jpg', 'Gà Không Xương Tẩm Bột\\r\\nThịt gà không xương được tẩm bột và chiên vàng, dễ dàng thưởng thức và phù hợp cho những ai muốn trải nghiệm phần thịt gà mềm thơm mà không cần lo về xương.', 1, 3),
(21, 'Gà Viên Nuggets', 'gv04', '1000', '0', '1730277685_gavien.jpg', 'Gà Viên Nuggets\\r\\nMiếng gà viên nhỏ nhắn, giòn rụm bên ngoài và mềm thơm bên trong, dễ ăn và cực kỳ tiện lợi, đặc biệt hấp dẫn với trẻ nhỏ.', 1, 3),
(22, 'Gà Rán Tẩm Mật Ong', 'gr05', '3000', '0', '1730277625_garanmatong.jpg', 'Gà Rán Tẩm Mật Ong\\r\\nGà rán tẩm mật ong ngọt dịu, với lớp vỏ giòn và chút vị ngọt nhẹ, tạo nên sự kết hợp hoàn hảo giữa mặn và ngọt, thơm lừng mỗi khi cắn.', 1, 3),
(23, 'Gà Rán Phô Mai', 'gr06', '1000', '0', '1730277566_garanphomai.jpg', 'Gà Rán Phô Mai\\r\\nMiếng gà rán phủ phô mai béo ngậy, hòa quyện vị giòn tan của lớp vỏ với vị mặn béo của phô mai tan chảy, tạo cảm giác thơm ngon khó cưỡng.', 1, 3),
(24, 'Gà Rán Cay', 'gr07', '1000', '0', '1730277511_garancay.jpg', 'Gà Rán Cay\\r\\nPhần gà rán cay nồng với lớp vỏ phủ bột ớt và các gia vị đặc biệt, kích thích vị giác với độ giòn tan cùng vị cay nhẹ từ ngoài vào trong.', 1, 3),
(25, 'Gà Rán Truyền Thống', 'gr01', '1000', '0', '1730279602_garan.jpg', 'Gà Rán Truyền Thống\\r\\nGà rán giòn rụm với lớp vỏ vàng ruộm, thấm đậm gia vị truyền thống, thịt bên trong mềm mọng, đem lại hương vị quen thuộc và hấp dẫn.', 1, 3),
(26, 'Bánh Brownie Chocolate', 'apw01', '1000', '0', '1730277382_BrownieChocolate.jpg', 'Bánh Brownie Chocolate\\r\\nBánh brownie đặc sánh vị chocolate đậm đà, thêm chút hạt óc chó và sốt chocolate, mềm mịn và béo nhẹ, rất hợp khi dùng kèm với một ly cà phê.', 1, 4),
(27, 'Kem Ly Vani & Chocolate', 'apw02', '1000', '0', '1730277326_vani.jpg', 'Phần kem hai vị vani và chocolate mát lạnh, kết hợp với topping hạt hạnh nhân và chocolate chip, tạo cảm giác ngọt ngào và sảng khoái cho ngày hè.', 1, 4),
(28, 'Nước Ép Cam Tươi', 'apw03', '1000', '0', '1730277278_camtuoi.jpg', 'Nước Ép Cam Tươi\\r\\nLy nước ép cam 100% từ cam tươi, cung cấp vitamin C, mang vị chua nhẹ và ngọt tự nhiên. Đồ uống này vừa tốt cho sức khỏe lại giải khát cực kỳ hiệu quả.', 1, 4),
(29, 'Sinh Tố Dâu Tây', 'apw04', '1000', '0', '1730277233_dautay.jpg', 'Sinh tố dâu tươi, ngọt dịu và hơi chua, được xay nhuyễn tạo kết cấu mịn màng, kèm chút kem tươi bên trên. Thức uống này vừa giải khát vừa bổ dưỡng.', 1, 4),
(30, 'Trà Sữa Trân Châu Đường Đen', 'apw05', '1000', '600', '1730277177_duongden.jpg', 'Trà Sữa Trân Châu Đường Đen\\r\\nThức uống trà sữa đậm vị trà, pha cùng trân châu mềm dẻo và đường đen ngọt ngào, thích hợp cho những ai yêu thích vị ngọt và sự béo nhẹ.', 1, 4),
(31, 'Nước Chanh Bạc Hà', 'apw06', '2000', '0', '1730277119_trachanhbacha.png', 'Ly nước chanh bạc hà chua ngọt hài hòa, được pha với chanh tươi và lá bạc hà thơm mát, giúp thanh lọc và làm mới vị giác.', 1, 4),
(32, 'Trà Đào Đá Xay', 'apw07', '1000', '600', '1730277016_tradao.jpg', 'Thức uống trà đào thơm ngon, pha cùng đá xay mát lạnh, điểm thêm vài miếng đào tươi, tạo cảm giác ngọt dịu và tươi mát.', 1, 4),
(33, 'Coca-Cola Đá Lạnh', 'apw08', '400', '100', '1730276928_coca.png', 'Ly Coca-Cola mát lạnh, sủi bọt, giúp giải khát tức thì với vị ngọt và hương thơm đặc trưng. Phù hợp với các món đồ chiên, giúp cân bằng hương vị.\\r\\n\\r\\n', 1, 4),
(34, 'Combo 5 – Combo Gà Nướng Healthy', 'spk01', '5000', '3000', '1730276653_food5.jpg', 'Combo 5 – Combo Gà Nướng Healthy\\r\\n\\r\\nMón chính: Gà nướng thảo mộc tươi với sốt chanh leo.\\r\\nMón phụ: Rau củ hấp với sốt bơ hoặc khoai tây nghiền.\\r\\nĐồ uống: Nước suối hoặc nước dừa tươi.\\r\\nTráng miệ', 1, 5),
(35, 'Combo 8 – Combo Hải Sản', 'spk02', '3000', '0', '1730276830_food8.jpg', 'Combo 8 – Combo Hải Sản\\r\\n\\r\\nMón chính: Một phần cá tẩm bột chiên giòn kèm tôm chiên xù.\\r\\nMón phụ: Salad tươi với các loại rau xanh và dưa chuột, kèm sốt mè rang.\\r\\nĐồ uống: Nước ngọt hoặc nước chanh d', 1, 5),
(36, 'Combo 7 – Combo Wraps & Rolls', 'spk03', '3000', '0', '1730276776_food7.jpg', 'Combo 7 – Combo Wraps & Rolls\\r\\n\\r\\nMón chính: Gói bánh mì wrap với nhân gà nướng, rau xanh và sốt Caesar.\\r\\nMón phụ: Phần khoai lang chiên giòn.\\r\\nĐồ uống: Nước chanh bạc hà hoặc nước ép dưa hấu.\\r\\nTráng miệng: M', 1, 5),
(37, 'Combo 6 – Combo Pizza & Pasta', 'spk04', '3000', '0', '1730276739_food6.jpg', 'Combo 6 – Combo Pizza & Pasta\\r\\n\\r\\nMón chính: Một phần pizza cá nhân (có thể chọn vị bò, hải sản hoặc rau củ).\\r\\nMón phụ: Mỳ Ý sốt cà chua với phô mai parmesan bào nhuyễn.\\r\\nĐồ uống: Nước ngọt hoặc trà đ', 1, 5),
(38, 'Combo 4 – Combo Burger Deluxe', 'spk05', '2000', '1000', '1730276572_food4.jpg', 'Combo 4 – Combo Burger Deluxe\\r\\n\\r\\nMón chính: Burger bò đặc biệt với thịt bò nướng than, thêm phô mai cheddar, hành tây caramen, và sốt BBQ.\\r\\nMón phụ: Phần khoai tây chiên curly (khoai chiên xoắn).\\r\\nĐồ uống: Sinh tố', 1, 5),
(39, 'Combo Gà Cay Khoai Lang', 'spk06', '2000', '0', '1730276454_food3.jpg', 'Combo 3 là phần ăn đa dạng và đầy đủ cho một bữa nhanh, bao gồm:\\r\\n\\r\\nMón chính: 3 miếng gà rán giòn tan với lớp vỏ vàng ruộm và thịt gà mềm bên trong.\\r\\nMón phụ: Khoai tây chiên và một phần salad tươi v', 1, 5),
(40, 'Combo Food 2', 'spk07', '3000', '0', '1730276271_food2.jpg', 'Combo 2 là một phần ăn nhanh tiện lợi, thường bao gồm các món cơ bản và phổ biến như:\\r\\n\\r\\nMón chính: Một burger bò hoặc gà với phô mai, xà lách, cà chua và sốt đặc trưng.\\r\\nMón phụ: Khoai tây chiên giòn, ', 1, 5),
(41, 'Combo FastFood 1', 'spk08', '3000', '1000', '1730276282_food1.jpg', 'Combo 1 là một phần ăn nhanh tiện lợi, thường bao gồm các món cơ bản và phổ biến như:\\r\\n\\r\\nMón chính: Một burger bò hoặc gà với phô mai, xà lách, cà chua và sốt đặc trưng.\\r\\nMón phụ: Khoai tây chiên giòn, ', 1, 5);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_thongke`
--

CREATE TABLE `tbl_thongke` (
  `id` int(11) NOT NULL,
  `ngaydat` varchar(30) NOT NULL,
  `donhang` int(11) NOT NULL,
  `doanhthu` varchar(100) NOT NULL,
  `soluongban` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_thongke`
--

INSERT INTO `tbl_thongke` (`id`, `ngaydat`, `donhang`, `doanhthu`, `soluongban`) VALUES
(2, '2024-11-06', 30, '2000', 30),
(4, '2024-11-06', 9, '5000', 3),
(6, '2024-11-06', 6, '25100', 11),
(7, '2024-11-06', 2, '9000', 2);

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `tbl_admin`
--
ALTER TABLE `tbl_admin`
  ADD PRIMARY KEY (`id_admin`);

--
-- Chỉ mục cho bảng `tbl_baiviet`
--
ALTER TABLE `tbl_baiviet`
  ADD PRIMARY KEY (`id_baiviet`);

--
-- Chỉ mục cho bảng `tbl_cart_details`
--
ALTER TABLE `tbl_cart_details`
  ADD PRIMARY KEY (`id_cart_details`),
  ADD KEY `id_sp` (`id_sp`);

--
-- Chỉ mục cho bảng `tbl_cart_registered`
--
ALTER TABLE `tbl_cart_registered`
  ADD PRIMARY KEY (`id_cart_registered`),
  ADD KEY `id_khachhang` (`id_khachhang`);

--
-- Chỉ mục cho bảng `tbl_cart_unregistered`
--
ALTER TABLE `tbl_cart_unregistered`
  ADD PRIMARY KEY (`id_cart_unregistered`);

--
-- Chỉ mục cho bảng `tbl_comments`
--
ALTER TABLE `tbl_comments`
  ADD PRIMARY KEY (`id_cmt`),
  ADD KEY `id_sp` (`id_sp`);

--
-- Chỉ mục cho bảng `tbl_dangky`
--
ALTER TABLE `tbl_dangky`
  ADD PRIMARY KEY (`id_khachhang`);

--
-- Chỉ mục cho bảng `tbl_danhmuc`
--
ALTER TABLE `tbl_danhmuc`
  ADD PRIMARY KEY (`id_danhmuc`);

--
-- Chỉ mục cho bảng `tbl_phanhoi`
--
ALTER TABLE `tbl_phanhoi`
  ADD PRIMARY KEY (`id_ph`);

--
-- Chỉ mục cho bảng `tbl_sanpham`
--
ALTER TABLE `tbl_sanpham`
  ADD PRIMARY KEY (`id_sp`),
  ADD KEY `id_danhmuc` (`id_danhmuc`);

--
-- Chỉ mục cho bảng `tbl_thongke`
--
ALTER TABLE `tbl_thongke`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `tbl_admin`
--
ALTER TABLE `tbl_admin`
  MODIFY `id_admin` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `tbl_baiviet`
--
ALTER TABLE `tbl_baiviet`
  MODIFY `id_baiviet` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `tbl_cart_details`
--
ALTER TABLE `tbl_cart_details`
  MODIFY `id_cart_details` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT cho bảng `tbl_cart_registered`
--
ALTER TABLE `tbl_cart_registered`
  MODIFY `id_cart_registered` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT cho bảng `tbl_cart_unregistered`
--
ALTER TABLE `tbl_cart_unregistered`
  MODIFY `id_cart_unregistered` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT cho bảng `tbl_comments`
--
ALTER TABLE `tbl_comments`
  MODIFY `id_cmt` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT cho bảng `tbl_dangky`
--
ALTER TABLE `tbl_dangky`
  MODIFY `id_khachhang` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT cho bảng `tbl_danhmuc`
--
ALTER TABLE `tbl_danhmuc`
  MODIFY `id_danhmuc` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `tbl_phanhoi`
--
ALTER TABLE `tbl_phanhoi`
  MODIFY `id_ph` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `tbl_sanpham`
--
ALTER TABLE `tbl_sanpham`
  MODIFY `id_sp` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT cho bảng `tbl_thongke`
--
ALTER TABLE `tbl_thongke`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `tbl_cart_details`
--
ALTER TABLE `tbl_cart_details`
  ADD CONSTRAINT `tbl_cart_details_ibfk_1` FOREIGN KEY (`id_sp`) REFERENCES `tbl_sanpham` (`id_sp`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Các ràng buộc cho bảng `tbl_cart_registered`
--
ALTER TABLE `tbl_cart_registered`
  ADD CONSTRAINT `tbl_cart_registered_ibfk_1` FOREIGN KEY (`id_khachhang`) REFERENCES `tbl_dangky` (`id_khachhang`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Các ràng buộc cho bảng `tbl_comments`
--
ALTER TABLE `tbl_comments`
  ADD CONSTRAINT `tbl_comments_ibfk_1` FOREIGN KEY (`id_sp`) REFERENCES `tbl_sanpham` (`id_sp`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Các ràng buộc cho bảng `tbl_sanpham`
--
ALTER TABLE `tbl_sanpham`
  ADD CONSTRAINT `tbl_sanpham_ibfk_1` FOREIGN KEY (`id_danhmuc`) REFERENCES `tbl_danhmuc` (`id_danhmuc`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
