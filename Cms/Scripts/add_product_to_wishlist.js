function addToWishlist(isvariableproduct) {
    // this is how you set it
    var quantity = document.getElementById("quantity").value;
    var size = "";
    var size2 = "";
    var uniqueid = Math.floor(Math.random() * 10000) + 1;
    if (isvariableproduct) {
        size = document.getElementsByClassName('select-box')[0].value;
        size2 = document.getElementsByClassName('select-box2')[0].value;
    }

    if (isvariableproduct && size === "") {
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
            "onclick": function () { document.location.href = '/wishlist'; }
        }
    }
    else {

        var storage = '';
        if (sessionStorage.wishlist === localStorage.wishlist) {
            storage = "session";
        } else {
            storage = "local";
        }

        if (storage === "session" && sessionStorage.wishlist) {
            wishlist = JSON.parse(sessionStorage.getItem('wishlist'));
        } else if (storage === "local" && localStorage.wishlist) {
            wishlist = JSON.parse(localStorage.getItem('wishlist'));
        }
        else {
            wishlist = [];
        }

        for (var i = 0; i < wishlist.length; i++) {
            if (id === wishlist[i].product && size === wishlist[i].size) {
                quantity = (parseInt(wishlist[i].quantity) + 1).toString(); //add two
                var index = wishlist.findIndex(i => i.product === id && i.size === size);
                if (index > -1) {
                    wishlist.splice(index, 1);
                }
            }
        }

        var wish = new Object();
        wish.id = uniqueid;
        wish.product = id;
        wish.quantity = quantity;
        wish.size = size;
        wish.size2 = size2;


        wishlist.push(wish);
        sessionStorage.setItem('wishlist', JSON.stringify(wishlist));
        localStorage.setItem('wishlist', JSON.stringify(wishlist));

        /* RETRIEVE*/
        var retrievedObject = sessionStorage.getItem('wishlist');
        var jsonObj = JSON.parse(retrievedObject);

        var result = Object.keys(jsonObj).map(function (key) {
            return jsonObj[key];
        });

        $.post("/wishsession", $.param({ wishValues: JSON.stringify(result) }, true));
        toastr["success"]("Produkt bol úspešne vložený do wishlistu. <a href='/wishlist'><u>Zobraziť wishlist</u></a>");
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
            "onclick": function () { document.location.href = '/wishlist'; }
        }
        document.getElementById("wishcount").innerHTML = result.length;
    }
}