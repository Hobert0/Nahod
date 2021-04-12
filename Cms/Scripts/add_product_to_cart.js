$(".button").on("click", function () {

    var $button = $(this);
    var oldValue = $button.parent().find("input").val();

    if ($button.text() == "+") {
        var newVal = parseFloat(oldValue) + 1;
    } else {
        // Don't allow decrementing below zero
        if (oldValue > 0) {
            newVal = parseFloat(oldValue) - 1;
        } else {
            newVal = 0;
        }
    }

    $button.parent().find("input").val(newVal);

});

function only2Decimals($num) {

    return (Math.floor($num * 100) / 100).toFixed(2);
}

$("#addproductbtn").click(function () {

    var isvariableproduct = $(this).attr('isvariableproduct');
    var quantity = document.getElementById("quantity").value;
    var variant = "";
    var variant2 = "";
    var price;
    if ($(".discount-price-text:not(.d-none)").length) {
        price = $(".discount-price-text:not(.d-none) .actual-price").text().replace(",", ".");
    } else {
        price = $(".w-discount-price:not(.d-none) .actual-price").text().replace(",", ".");
    } 
    //var price = $(".discount-price-text:not(.d-none)").hasClass("d-none") ? $(".w-discount-price .actual-price").text().replace(",", ".") : $(".discount-price-text .actual-price").text().replace(",",".");
    var uniqueid = Math.floor(Math.random() * 10000) + 1;

    if (isvariableproduct === "True") {
        variant = $(".product-variation select").eq(0).find("option:selected").text();

        if ($(".product-variation select").length == 2) {
            variant2 = $(".product-variation select").eq(1).find("option:selected").text();
        }
    }
    
    var storage = '';
    if (sessionStorage.addtocart === localStorage.addtocart) {
        storage = "session";
    } else {
        storage = "local";
    }

    if (storage === "session" && sessionStorage.addtocart) {
        addtocart = JSON.parse(sessionStorage.getItem('addtocart'));
    } else if (storage === "local" && localStorage.addtocart) {
        addtocart = JSON.parse(localStorage.getItem('addtocart'));
    }
    else {
        addtocart = [];
    }

    for (var i = 0; i < addtocart.length; i++) {
        if (id === addtocart[i].product && variant === addtocart[i].variant) {
            var index = addtocart.findIndex(i => i.product === id && i.variant === variant);
            if (index > -1) {

                addtocart.splice(index, 1);
            }
        }
    }

    console.log(price);

    var cart = new Object();
    cart.id = uniqueid;
    cart.product = id;
    cart.quantity = quantity;
    cart.price = price;
    cart.variant = variant;
    cart.variant2 = variant2;

    addtocart.push(cart);

    $sum = 0;
    for (var i = 0; i < addtocart.length; i++) {
        $sum += addtocart[i].quantity * addtocart[i].price;
    }

    //$sum = only2Decimals($sum);

    sessionStorage.setItem('addtocart', JSON.stringify(addtocart));
    localStorage.setItem('addtocart', JSON.stringify(addtocart));

    /* RETRIEVE*/
    var retrievedObject = sessionStorage.getItem('addtocart');
    var jsonObj = JSON.parse(retrievedObject);

    var result = Object.keys(jsonObj).map(function (key) {
        return jsonObj[key];
    });

    $.post("/cartsession", $.param({ cartValues: JSON.stringify(result) }, true));

    toastr["success"]("Produkt bol úspešne vložený do košíka. <a href='/kosik'><u>Zobraziť košík</u></a>");
    toastr.options = {
        "closeButton": true,
        "debug": false,
        "newestOnTop": false,
        "progressBar": false,
        "positionClass": "toast-top-right",
        "preventDuplicates": false,
        "showDuration": "300",
        "hideDuration": "1000",
        "timeOut": "5000",
        "extendedTimeOut": "1000",
        "showEasing": "swing",
        "hideEasing": "linear",
        "showMethod": "fadeIn",
        "hideMethod": "fadeOut",
        "onclick": function () { document.location.href = '/kosik'; }
    }

    document.getElementById("cart-qty").innerHTML = result.length;
    document.getElementById("cart-total").innerHTML = $sum + " €";
    


});