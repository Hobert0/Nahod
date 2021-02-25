$(document).ready(function () {
    var url = window.location;
    // for sidebar menu but not for treeview submenu
    $('.sidenav a').filter(function () {
        return this.href == url;
    }).parentsUntil(".categories").siblings(".dropdown-container").removeClass('activedrop').end().addClass('activedrop');

    // for treeview which is like a submenu
    $('.sidenav a').filter(function () {
        return this.href == url;
    }).parentsUntil(".sub_catsmenu").removeClass('activemenu').end().addClass('activemenu');
});

//* Loop through all dropdown buttons to toggle between hiding and showing its dropdown content - This allows the user to have multiple dropdowns without any conflict */
var dropdown = document.getElementsByClassName("dropdown-btn");
var i;

for (i = 0; i < dropdown.length; i++) {
    dropdown[i].addEventListener("click", function () {
        this.classList.toggle("active");
        var dropdownContent = getNextSibling(this, '.dropdown-container');
        if (dropdownContent.style.display === "block") {
            dropdownContent.style.display = "none";
        } else {
            dropdownContent.style.display = "block";
        }
    });
}

var getNextSibling = function (elem, selector) {

    // Get the next sibling element
    var sibling = elem.nextElementSibling;

    // If there's no selector, return the first sibling
    if (!selector) return sibling;

    // If the sibling matches our selector, use it
    // If not, jump to the next sibling and continue the loop
    while (sibling) {
        if (sibling.matches(selector)) return sibling;
        sibling = sibling.nextElementSibling
    }

};