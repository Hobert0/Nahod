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

$("#addproductbtn").click(function () {

    var isvariableproduct = $(this).attr('isvariableproduct');
    var isvariablecolor = $(this).attr('isvariablecolor');
    // this is how you set it
    var quantity = document.getElementById("quantity").value;
    var size = "";
    var size2 = "";
    var color = "";
    var price = $("#actual-price").text().replace(",",".");
    var uniqueid = Math.floor(Math.random() * 10000) + 1;
    if (isvariableproduct === "True") {
        size = document.getElementsByClassName('select-box')[0].value;
        size2 = document.getElementsByClassName('select-box2')[0].value;
    }
    if (isvariablecolor === "True") {
        color = document.getElementsByClassName('color-box')[0].value;
    }

    if (isvariableproduct === "True" && size === "") {
        toastr["warning"]("Zvoľte veľkosť produktu.");
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
    } else if (isvariablecolor  === "True" && color === "") {
        toastr["warning"]("Zvoľte variant produktu.");
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
            if (id === addtocart[i].product && size === addtocart[i].size && color === addtocart[i].color) {
                var index = addtocart.findIndex(i => i.product === id && i.size === size);
                if (index > -1) {

                    addtocart.splice(index, 1);
                }
            }
        }

        var cart = new Object();
        cart.id = uniqueid;
        cart.product = id;
        cart.quantity = quantity;
        cart.price = price;
        cart.size = size;
        cart.size2 = size2;
        cart.color = color;

        addtocart.push(cart);

        $sum = 0;
        for (var i = 0; i < addtocart.length; i++) {
            $sum += addtocart[i].quantity * addtocart[i].price;
        }

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

        console.log($sum + " €");

        document.getElementById("cart-qty").innerHTML = result.length;
        document.getElementById("cart-total").innerHTML = $sum + " €";
    }


});