$(document).ready(function () {
    thongke();
    var char = new Morris.Area({
        element: "chart",

        xkey: "date",

        ykeys: ["order", "sales", "quantity"],

        labels: ["Đơn hàng", "Doanh thu", "Số lượng bán ra"],
    });

    $(".select-date").change(function () {
        var thoigian = $(this).val();
        if (thoigian == "homnay") {
            var text = "Hôm nay";
        } else if (thoigian == "7ngay") {
            var text = "7 ngày qua";
        } else if (thoigian == "28ngay") {
            var text = "28 ngày qua";
        } else if (thoigian == "90ngay") {
            var text = "90 ngày qua";
        } else {
            var text = "365 ngày qua";
        }

        $.ajax({
            url: "modules/thongke.php",
            method: "POST",
            dataType: "JSON",
            data: { thoigian: thoigian },
            success: function (data) {
                char.setData(data);
                $("#text-date").text(text);
            },
        });
    });
    function thongke() {
        var text = "Hôm nay";
        $("#text-date").text(text);
        $.ajax({
            url: "modules/thongke.php",
            method: "POST",
            dataType: "JSON",
            success: function (data) {
                char.setData(data);
                $("#text-date").text(text);
            },
        });
    }
});
