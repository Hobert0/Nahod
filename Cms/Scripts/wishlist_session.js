// this is how you will retrive it

var retrievedObject = document.getElementById("myDiv").value;

var jsonObj = JSON.parse(retrievedObject);

var result = Object.keys(jsonObj).map(function (key) {
    return jsonObj[key];
});

function decreaseCount(productid) {
    var retrievedObject = document.getElementById("myDiv").value;
    var quantity = document.getElementById("quantity-" + productid + "").value;
    quantity = parseInt(quantity) - 1;
    // this is how you set it
    var wish = new Object();

    wish.id = productid;
    wish.quantity = quantity.toString();

    if (retrievedObject != "null") {
        wishlist = JSON.parse(retrievedObject);
    } else {
        wishlist = [];
    }
    for (var i = 0; i < wishlist.length; i++) {
        if (productid === wishlist[i].id) {
            wish.product = wishlist[i].product;
            wish.size = wishlist[i].size;
            wish.size2 = wishlist[i].size2;
        }
    }

    if (wish.quantity === "0") {
        removeFromWishlist(productid.toString());
    } else {  
        wishlist.push(wish);
        var index = wishlist.findIndex(i => i.id === productid);
        if (index > -1) {
            wishlist.splice(index, 1);
        }
        sessionStorage.setItem('wishlist', JSON.stringify(wishlist));
        localStorage.setItem('wishlist', JSON.stringify(wishlist));


        /* RETRIEVE*/
        var retrievedObject = sessionStorage.getItem('wishlist');
        var jsonObj = JSON.parse(retrievedObject);

        var result = Object.keys(jsonObj).map(function (key) {
            return jsonObj[key];
        });
        $.post("/wishsession", $.param({ wishValues: JSON.stringify(result) }, true));

        window.location.reload();
    }
}

function increaseCount(productid) {
    var retrievedObject = document.getElementById("myDiv").value;
    var quantity = document.getElementById("quantity-" + productid + "").value;
    quantity = parseInt(quantity) + 1;
    // this is how you set it
    var wish = new Object();

    wish.id = productid;
    wish.quantity = quantity.toString();

    if (retrievedObject) {
        wishlist = JSON.parse(retrievedObject);
    } else {
        wishlist = [];
    }

    for (var i = 0; i < wishlist.length; i++) {
        if (productid === wishlist[i].id) {
            wish.product = wishlist[i].product;
            wish.size = wishlist[i].size;
            wish.size2 = wishlist[i].size2;
        }
    }

    wishlist.push(wish);
    var index = wishlist.findIndex(i => i.id === productid);
    if (index > -1) {
        wishlist.splice(index, 1);
    }
    sessionStorage.setItem('wishlist', JSON.stringify(wishlist));
    localStorage.setItem('wishlist', JSON.stringify(wishlist));


    /* RETRIEVE*/
    var retrievedObject = sessionStorage.getItem('wishlist');
    var jsonObj = JSON.parse(retrievedObject);

    var result = Object.keys(jsonObj).map(function (key) {
        return jsonObj[key];
    });
    $.post("/wishsession", $.param({ wishValues: JSON.stringify(result) }, true));

    window.location.reload();
}

function refreshWishlist() {
    // this is how you set it

    var storage = '';
    if (sessionStorage.wishlist === localStorage.wishlist) {
        storage = "session";
    } else {
        storage = "local";
    }

    if (storage === "session" && sessionStorage.wishlist) {
        wishlist = JSON.parse(sessionStorage.getItem('wishlist'));
    } else if (storage === "local" && localStorage.wishlist){
        wishlist = JSON.parse(localStorage.getItem('wishlist'));
    }
    else {
        wishlist = [];
    }

    for (var i = 0; i < wishlist.length; i++) {
        if (wishlist[i].quantity !== "0"){
        wishlist[i].quantity = document.getElementById("quantity-" + wishlist[i].id + "").value;  //add two
        }
    }

    sessionStorage.setItem('wishlist', JSON.stringify(wishlist));
    localStorage.setItem('wishlist', JSON.stringify(wishlist));

    /* RETRIEVE*/
    var retrievedObject = sessionStorage.getItem('wishlist');
    var jsonObj = JSON.parse(retrievedObject);

    var result = Object.keys(jsonObj).map(function (key) {
        return jsonObj[key];
    });
    $.post("/wishsession", $.param({ wishValues: JSON.stringify(result) }, true));

    window.location.reload();
}

function removeFromWishlist(event) {
    // this is how you set it
    var wishlist = new Object();
    var productid = event;
    var index = -1;

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
        var idecko = wishlist[i].id;
        if (productid === idecko.toString()) {
            index = i;
        }
    }

    if (index === 0) {
        wishlist.shift();
    } else if (index > -1) {
        wishlist.splice(index, 1);
    }
    sessionStorage.setItem('wishlist', JSON.stringify(wishlist));
    localStorage.setItem('wishlist', JSON.stringify(wishlist));

    /* RETRIEVE*/
    var retrievedObject = sessionStorage.getItem('wishlist');
    var jsonObj = JSON.parse(retrievedObject);

    var result = Object.keys(jsonObj).map(function (key) {
        return jsonObj[key];
    });
    $.post("/wishsession", $.param({ wishValues: JSON.stringify(result) }, true));

    window.location.reload();
}