// todo slick slider pro sale
$(".container-product-sales-slider").slick({
    dots: false,
    infinite: false,
    speed: 400,
    slidesToShow: 5,
    slidesToScroll: 2,
    autoplay: true,
    autoplaySpeed: 3000,
    prevArrow:
        '<button class="slick-prev slick-arrow"><i class="fa-solid fa-angle-left" aria-hidden="true"></i></button>',
    nextArrow:
        '<button class="slick-next slick-arrow"><i class="fa-solid fa-angle-right" aria-hidden="true"></fa-solid></button>',
    responsive: [
        {
            breakpoint: 1024,
            settings: {
                slidesToShow: 3,
                slidesToScroll: 3,
            },
        },
        {
            breakpoint: 600,
            settings: {
                slidesToShow: 2,
                slidesToScroll: 2,
            },
        },
        {
            breakpoint: 480,
            settings: {
                slidesToShow: 1,
                slidesToScroll: 1,
            },
        },
        // You can unslick at a given breakpoint now by adding:
        // settings: "unslick"
        // instead of a settings object
    ],
});
// todo slick slider pro iphone
$(".container-product-iphone-slider").slick({
    dots: false,
    infinite: false,
    slidesToShow: 5,
    slidesToScroll: 2,
    autoplay: true,
    autoplaySpeed: 3000,
    prevArrow:
        '<button class="slick-prev slick-arrow"><i class="fa-solid fa-angle-left" aria-hidden="true"></i></button>',
    nextArrow:
        '<button class="slick-next slick-arrow"><i class="fa-solid fa-angle-right" aria-hidden="true"></fa-solid></button>',
    responsive: [
        {
            breakpoint: 1024,
            settings: {
                slidesToShow: 3,
                slidesToScroll: 3,
                infinite: true,
                dots: true,
            },
        },
        {
            breakpoint: 600,
            settings: {
                slidesToShow: 2,
                slidesToScroll: 2,
            },
        },
        {
            breakpoint: 480,
            settings: {
                slidesToShow: 1,
                slidesToScroll: 1,
            },
        },
        // You can unslick at a given breakpoint now by adding:
        // settings: "unslick"
        // instead of a settings object
    ],
});
// todo slick slider pro ipad
$(".container-product-ipad-slider").slick({
    dots: false,
    infinite: false,
    slidesToShow: 5,
    slidesToScroll: 2,
    autoplay: true,
    autoplaySpeed: 3000,
    prevArrow:
        '<button class="slick-prev slick-arrow"><i class="fa-solid fa-angle-left" aria-hidden="true"></i></button>',
    nextArrow:
        '<button class="slick-next slick-arrow"><i class="fa-solid fa-angle-right" aria-hidden="true"></fa-solid></button>',
    responsive: [
        {
            breakpoint: 1024,
            settings: {
                slidesToShow: 3,
                slidesToScroll: 3,
                infinite: true,
                dots: true,
            },
        },
        {
            breakpoint: 600,
            settings: {
                slidesToShow: 2,
                slidesToScroll: 2,
            },
        },
        {
            breakpoint: 480,
            settings: {
                slidesToShow: 1,
                slidesToScroll: 1,
            },
        },
        // You can unslick at a given breakpoint now by adding:
        // settings: "unslick"
        // instead of a settings object
    ],
});
// todo slick slider blogs
$(".container-blogs-slider").slick({
    dots: false,
    infinite: false,
    slidesToShow: 3,
    slidesToScroll: 2,
    autoplay: true,
    autoplaySpeed: 3000,
    prevArrow:
        '<button class="slick-prev slick-arrow"><i class="fa-solid fa-angle-left" aria-hidden="true"></i></button>',
    nextArrow:
        '<button class="slick-next slick-arrow"><i class="fa-solid fa-angle-right" aria-hidden="true"></fa-solid></button>',
    responsive: [
        {
            breakpoint: 1024,
            settings: {
                slidesToShow: 3,
                slidesToScroll: 3,
                infinite: true,
                dots: true,
            },
        },
        {
            breakpoint: 600,
            settings: {
                slidesToShow: 2,
                slidesToScroll: 2,
            },
        },
        {
            breakpoint: 480,
            settings: {
                slidesToShow: 1,
                slidesToScroll: 1,
            },
        },
        // You can unslick at a given breakpoint now by adding:
        // settings: "unslick"
        // instead of a settings object
    ],
});
