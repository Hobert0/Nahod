﻿// this is how you will retrive it

var retrievedObject = sessionStorage.getItem('addtocart');
var jsonObj = JSON.parse(retrievedObject);

var result = Object.keys(jsonObj).map(function (key) {
    return jsonObj[key];
});

function decreaseCount(productid) {
    var quantity = document.getElementById("quantity-" + productid + "").value;
    quantity = parseInt(quantity) - 1;
 // this is how you set it
    var cart = new Object();

    cart.id = productid;
    cart.quantity = quantity.toString();

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
        if (productid === addtocart[i].id) {
            cart.product = addtocart[i].product;
            cart.variant = addtocart[i].variant;
            cart.variant2 = addtocart[i].variant2;
            cart.price = addtocart[i].price;
        }
    }

    if (cart.quantity === "0") {
        removeFromCart(productid.toString());
    } else {        
        addtocart.push(cart);
        var index = addtocart.findIndex(i => i.id === productid);
        if (index > -1) {
            addtocart.splice(index, 1);
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

        window.location.reload();
    }
}

function increaseCount(productid) {
    var quantity = document.getElementById("quantity-"+productid+"").value;
    quantity = parseInt(quantity) + 1;
    // this is how you set it
    var cart = new Object();

    cart.id = productid;
    cart.quantity = quantity.toString();
    
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
        if (productid === addtocart[i].id) {
            cart.product = addtocart[i].product;
            cart.variant = addtocart[i].variant;
            cart.variant2 = addtocart[i].variant2;
            cart.price = addtocart[i].price;
        }
    }

    addtocart.push(cart);
    var index = addtocart.findIndex(i => i.id === productid);
    if (index > -1) {
        addtocart.splice(index, 1);
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

    window.location.reload();
}

function refreshCart() {
    // this is how you set it

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
        if (addtocart[i].quantity !== "0"){
            addtocart[i].quantity = document.getElementById("quantity-" + addtocart[i].id).value;  //add two
        }
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

    window.location.reload();
}

function removeFromCart(event) {
    // this is how you set it
    var addtocart = new Object();
    var productid = event;
    var index = -1;

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
        var idecko = addtocart[i].id;
        if (productid === idecko.toString()) {
            index = i;
        }
    }

    if (index === 0) {
        addtocart.shift();
    } else if (index > -1) {
        addtocart.splice(index, 1);
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

    window.location.reload();
}