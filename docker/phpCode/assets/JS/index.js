const btnSearch = document.querySelector(".js-button-search");
const search = document.querySelector(".js-search");
const navmenu = document.querySelector(".js-navmenu");

function showSearch() {
    search.classList.add("show");
}

function hideSearch() {
    search.classList.remove("show");
}

btnSearch.addEventListener("click", showSearch);
navmenu.addEventListener("click", hideSearch);

btnSearch.addEventListener("click", function (event) {
    event.stopPropagation();
});

search.addEventListener("click", function (event) {
    event.stopPropagation();
});

// todo sticky menu
window.addEventListener("scroll", function () {
    var navMenu = document.querySelector(".js-navmenu");
    navMenu.classList.toggle("sticky", window.scrollY > 0);
});

//todo quảng cáo
const adv = document.querySelector(".js-adv");
const btnClose = document.querySelector(".js-close-adv");

function showAdv() {
    adv.classList.add("open");
}
function hideAdv() {
    adv.classList.remove("open");
}

setTimeout(showAdv, 3000);
btnClose.addEventListener("click", hideAdv);

// todo go to top
window.addEventListener("scroll", function () {
    var goTop = document.querySelector(".js-top");
    goTop.classList.toggle("open", window.scrollY > 0);
});
