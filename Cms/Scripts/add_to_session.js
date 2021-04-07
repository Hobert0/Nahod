﻿function only2Decimals($num) {
    return (Math.floor($num * 100) / 100).toFixed(2);
}

function addToCart(id, variableproduct, price) {
    // this is how you set it
    var quantity = "1";
    var variant = "";
    var variant2 = "";
    var uniqueid = Math.floor(Math.random() * 10000) + 1;

    if (variableproduct === true) {
        toastr["warning"]("Pre objednávku je potrebné v detaile produktu zvoliť variant.");
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
    }
    else {

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
                quantity = (parseInt(addtocart[i].quantity) + 1).toString(); //add two
                var index = addtocart.findIndex(i => i.product === id && i.variant === variant);
                if (index > -1) {
                    addtocart.splice(index, 1);
                }
            }
        }

        var cart = new Object();
        cart.id = uniqueid;
        cart.variant = variant;
        cart.variant2 = variant2;
        cart.quantity = quantity;
        cart.product = id;
        cart.price = price;


        addtocart.push(cart);

        $sum = 0;
        for (var i = 0; i < addtocart.length; i++) {
            $sum += addtocart[i].quantity * addtocart[i].price;
        }

        $sum = only2Decimals($sum);

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
            "onclick": function () { document.location.href = '/kosik' }
        }
        document.getElementById("cart-qty").innerHTML = result.length;
        document.getElementById("cart-total").innerHTML = $sum + " €";
    }
}