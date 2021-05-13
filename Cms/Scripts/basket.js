function shippPay() {

    var ship = document.querySelector('input[name="transfer"]:checked').value;
    if (isNaN(eval(ship))) { ship = 0; } else { ship = eval(ship); }
    if (document.querySelectorAll('input[name="payment"]:checked').length === 0) {

        document.getElementById("pricedph").innerHTML =
            (Math.round(Number(finalprice) + eval(ship)) * 100 / 120).toFixed(2);
        document.getElementById("final").innerHTML = (Number(finalprice) + eval(ship)).toFixed(2);
        document.getElementById("pricedph2").innerHTML =
            (Math.round(Number(finalprice) + eval(ship)) * 100 / 120).toFixed(2);
        document.getElementById("final2").innerHTML = (Number(finalprice) + eval(ship)).toFixed(2);
        document.getElementById("final3").value = (Number(finalprice) + eval(ship)).toFixed(2);

    } else {

        var pay = document.querySelector('input[name="payment"]:checked').value;
        if (isNaN(eval(pay))) { pay = 0; } else { pay = eval(pay); }
        document.getElementById("pricedph").innerHTML =
            (Math.round(Number(finalprice) + eval(ship) + pay) * 100 / 120).toFixed(2);
        document.getElementById("final").innerHTML = (Number(finalprice) + eval(ship) + pay).toFixed(2);
        document.getElementById("pricedph2").innerHTML =
            (Math.round(Number(finalprice) + eval(ship) + pay) * 100 / 120).toFixed(2);
        document.getElementById("final2").innerHTML = (Number(finalprice) + eval(ship) + pay).toFixed(2);
        document.getElementById("final3").value = (Number(finalprice) + eval(ship) + pay).toFixed(2);

    }
}

function payMent() {
    var pay = document.querySelector('input[name="payment"]:checked').value;
    if (isNaN(eval(pay))) { pay = 0; } else { pay = eval(pay); }
    if (document.querySelectorAll('input[name="transfer"]:checked').length === 0) {

        document.getElementById("pricedph").innerHTML =
            (Math.round(Number(finalprice) + eval(pay)) * 100 / 120).toFixed(2);
        document.getElementById("final").innerHTML = (Number(finalprice) + eval(pay)).toFixed(2);
        document.getElementById("pricedph2").innerHTML =
            (Math.round(Number(finalprice) + eval(pay)) * 100 / 120).toFixed(2);
        document.getElementById("final2").innerHTML = (Number(finalprice) + eval(pay)).toFixed(2);
        document.getElementById("final3").value = (Number(finalprice) + eval(pay)).toFixed(2);

    } else {
        var ship = document.querySelector('input[name="transfer"]:checked').value;
        if (isNaN(eval(ship))) { ship = 0; } else { ship = eval(ship); }
        document.getElementById("pricedph").innerHTML =
            (Math.round(Number(finalprice) + eval(ship) + eval(pay)) * 100 / 120).toFixed(2);
        document.getElementById("final").innerHTML = (Number(finalprice) + eval(ship) + eval(pay)).toFixed(2);
        document.getElementById("pricedph2").innerHTML =
            (Math.round(Number(finalprice) + eval(ship) + eval(pay)) * 100 / 120).toFixed(2);
        document.getElementById("final2").innerHTML = (Number(finalprice) + eval(ship) + eval(pay)).toFixed(2);
        document.getElementById("final3").value = (Number(finalprice) + eval(ship) + eval(pay)).toFixed(2);

    }
}

function checkTransfer() {
    var ship = document.querySelector('input[name="transfer"]:checked').value;
    document.getElementById("ship").value = ship;
    ship == '@ViewBag.Ship';
    if (ship == "transfer3") {
        if (document.getElementById("pay4") != null)
            document.getElementById("pay4").style.display = "none";
    } else {
        if (document.getElementById("pay4") != null)
            document.getElementById("pay4").style.display = "block";
    }

    if (ship == "transfer1" || ship == "transfer2") {
        if (document.getElementById("pay1") != null)
            document.getElementById("pay1").style.display = "none";
    } else {
        if (document.getElementById("pay1") != null)
            document.getElementById("pay1").style.display = "block";
    }

}
function checkPayment() {
    var pay = document.querySelector('input[name="payment"]:checked').value;
    document.getElementById("platba").value = pay;
    pay == '@ViewBag.Pay';
    if (pay == "pay4") {
        if (document.getElementById("transfer3") != null)
            document.getElementById("transfer3").style.display = "none";
    } else {
        if (document.getElementById("transfer3") != null)
            document.getElementById("transfer3").style.display = "block";
    }

    if (pay == "pay1") {
        if (document.getElementById("transfer1") != null)
            document.getElementById("transfer1").style.display = "none";
    } else {
        if (document.getElementById("transfer1") != null)
            document.getElementById("transfer1").style.display = "block";
    }
}

function showShipping() {
    var cart = document.getElementById("cart");
    var shipping = document.getElementById("shipping");
    var address = document.getElementById("address");

    cart.style.display = "none";
    shipping.style.display = "block";
    address.style.display = "none";

}

function showAddress(userId) {
    var modal = document.getElementById("myModal");
    var transradio = document.getElementsByName("transfer");
    var payradio = document.getElementsByName("payment");
    if (validateRadio(transradio) && validateRadio(payradio)) {
        var cart = document.getElementById("cart");
        var shipping = document.getElementById("shipping");
        var address = document.getElementById("address");
        cart.style.display = "none";
        shipping.style.display = "none";
        address.style.display = "block";

        /*
        if (userId == null) {
            modal.style.display = "block";
        }
        */
        
    } else {
        toastr["warning"]("Zvoľte spôsob dopravy a platby.");
        toastr.options = {
            "closeButton": true,
            "debug": false,
            "newestOnTop": false,
            "progressBar": false,
            "positionClass": "toast-top-right",
            "preventDuplicates": false,
            "onclick": null,
            "showDuration": "300",
            "hideDuration": "1000",
            "timeOut": "5000",
            "extendedTimeOut": "1000",
            "showEasing": "swing",
            "hideEasing": "linear",
            "showMethod": "fadeIn",
            "hideMethod": "fadeOut"
        }
    }

}

function showCart() {
    var cart = document.getElementById("cart");
    var shipping = document.getElementById("shipping");
    var address = document.getElementById("address");
    cart.style.display = "block";
    shipping.style.display = "none";
    address.style.display = "none";
}

function shippingAddr() {
    var checkBox = document.getElementById("myCheck");
    var shippingAdr = document.getElementById("shippingAdr");
    if (checkBox.checked == true) {
        shippingAdr.style.display = "block";
    } else {
        shippingAdr.style.display = "none";
    }
}

function validateRadio(radios) {
    for (i = 0; i < radios.length; ++i) {
        if (radios[i].checked) return true;
    }
    return false;
}

function validateBasketForm() {
    var checkBox = document.getElementById("myCheck");
    var condition = document.getElementById("conditionbask");

    var name = document.getElementsByName("OrdersModel.Name")[0].value;
    var surname = document.getElementsByName("OrdersModel.Surname")[0].value;
    var address = document.getElementsByName("OrdersModel.Address")[0].value;
    var city = document.getElementsByName("OrdersModel.City")[0].value;
    var zip = document.getElementsByName("OrdersModel.Zip")[0].value;
    var country = document.getElementsByName("OrdersModel.Country")[0].value;
    var phone = document.getElementsByName("OrdersModel.Phone")[0].value;
    var email = document.getElementsByName("OrdersModel.Email")[0].value;

    var name_ship = document.getElementsByName("OrdersModel.NameShipp")[0].value;
    var surname_ship = document.getElementsByName("OrdersModel.SurnameShipp")[0].value;
    var address_ship = document.getElementsByName("OrdersModel.AddressShipp")[0].value;
    var city_ship = document.getElementsByName("OrdersModel.CityShipp")[0].value;
    var zip_ship = document.getElementsByName("OrdersModel.ZipShipp")[0].value;
    var country_ship = document.getElementsByName("OrdersModel.CountryShipp")[0].value;
    var phone_ship = document.getElementsByName("OrdersModel.PhoneShipp")[0].value;

    if (checkBox.checked == true) {
        if (name != "" &&
            surname != "" &&
            address != "" &&
            city != "" &&
            zip != "" &&
            country != "" &&
            phone != "" &&
            email != "" &&
            validateEmail(email) == true &&
            name_ship != "" &&
            surname_ship != "" &&
            address_ship != "" &&
            city_ship != "" &&
            zip_ship != "" &&
            country_ship != "" &&
            phone_ship != "") {
            if (condition.checked === true) {
                return true;
            } else {
                document.getElementById("conditioncheckbask").style.border = "1px solid #ff4545";
                toastr["error"]("Je potrebné súhlasiť s obchodnými podmienkami a podmienkami ochrany osobných údajov.");

                toastr.options = {
                    "closeButton": true,
                    "debug": false,
                    "newestOnTop": false,
                    "progressBar": false,
                    "positionClass": "toast-top-right",
                    "preventDuplicates": false,
                    "onclick": null,
                    "showDuration": "300",
                    "hideDuration": "1000",
                    "timeOut": "5000",
                    "extendedTimeOut": "1000",
                    "showEasing": "swing",
                    "hideEasing": "linear",
                    "showMethod": "fadeIn",
                    "hideMethod": "fadeOut"
                }
                return false;
            }
        } else {
            if (name == "") {
                document.getElementsByName("OrdersModel.Name")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.Name")[0].style.borderColor = "#ced4da";

            }
            if (surname == "") {
                document.getElementsByName("OrdersModel.Surname")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.Surname")[0].style.borderColor = "#ced4da";

            }
            if (address == "") {
                document.getElementsByName("OrdersModel.Address")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.Address")[0].style.borderColor = "#ced4da";

            }
            if (city == "") {
                document.getElementsByName("OrdersModel.City")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.City")[0].style.borderColor = "#ced4da";

            }
            if (zip == "") {
                document.getElementsByName("OrdersModel.Zip")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.Zip")[0].style.borderColor = "#ced4da";

            }
            if (country == "") {
                document.getElementsByName("OrdersModel.Country")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.Country")[0].style.borderColor = "#ced4da";

            }
            if (phone == "") {
                document.getElementsByName("OrdersModel.Phone")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.Phone")[0].style.borderColor = "#ced4da";

            }
            if (email == "" || validateEmail(email) != true) {
                document.getElementsByName("OrdersModel.Email")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.Email")[0].style.borderColor = "#ced4da";

            }
            if (name_ship == "") {
                document.getElementsByName("OrdersModel.NameShipp")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.NameShipp")[0].style.borderColor = "#ced4da";

            }
            if (surname_ship == "") {
                document.getElementsByName("OrdersModel.SurnameShipp")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.SurnameShipp")[0].style.borderColor = "#ced4da";

            }
            if (address_ship == "") {
                document.getElementsByName("OrdersModel.AddressShipp")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.AddressShipp")[0].style.borderColor = "#ced4da";

            }
            if (city_ship == "") {
                document.getElementsByName("OrdersModel.CityShipp")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.CityShipp")[0].style.borderColor = "#ced4da";

            }
            if (zip_ship == "") {
                document.getElementsByName("OrdersModel.ZipShipp")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.ZipShipp")[0].style.borderColor = "#ced4da";

            }
            if (country_ship == "") {
                document.getElementsByName("OrdersModel.CountryShipp")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.CountryShipp")[0].style.borderColor = "#ced4da";

            }
            if (phone_ship == "") {
                document.getElementsByName("OrdersModel.PhoneShipp")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.PhoneShipp")[0].style.borderColor = "#ced4da";

            }
            toastr["warning"]("Údaje nie sú vyplnené alebo sú vyplnené nesprávne.");
            toastr.options = {
                "closeButton": true,
                "debug": false,
                "newestOnTop": false,
                "progressBar": false,
                "positionClass": "toast-top-right",
                "preventDuplicates": false,
                "onclick": null,
                "showDuration": "300",
                "hideDuration": "1000",
                "timeOut": "5000",
                "extendedTimeOut": "1000",
                "showEasing": "swing",
                "hideEasing": "linear",
                "showMethod": "fadeIn",
                "hideMethod": "fadeOut"
            }
            return false;
        }
    } else {
        if (name != "" && surname != "" && address != "" && city != "" && zip != "" && country != "" && phone != "" && email != "" && validateEmail(email) == true) {
            if (condition.checked == true) {
                return true;
            } else {
                document.getElementById("conditioncheckbask").style.border = "1px solid #ff4545";
                toastr["error"]("Je potrebné súhlasiť s obchodnými podmienkami a podmienkami ochrany osobných údajov.");

                toastr.options = {
                    "closeButton": true,
                    "debug": false,
                    "newestOnTop": false,
                    "progressBar": false,
                    "positionClass": "toast-top-right",
                    "preventDuplicates": false,
                    "onclick": null,
                    "showDuration": "300",
                    "hideDuration": "1000",
                    "timeOut": "5000",
                    "extendedTimeOut": "1000",
                    "showEasing": "swing",
                    "hideEasing": "linear",
                    "showMethod": "fadeIn",
                    "hideMethod": "fadeOut"
                }
                return false;
            }

        } else {
            if (name == "") {
                document.getElementsByName("OrdersModel.Name")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.Name")[0].style.borderColor = "#ced4da";

            }
            if (surname == "") {
                document.getElementsByName("OrdersModel.Surname")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.Surname")[0].style.borderColor = "#ced4da";

            }
            if (address == "") {
                document.getElementsByName("OrdersModel.Address")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.Address")[0].style.borderColor = "#ced4da";

            }
            if (city == "") {
                document.getElementsByName("OrdersModel.City")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.City")[0].style.borderColor = "#ced4da";

            }
            if (zip == "") {
                document.getElementsByName("OrdersModel.Zip")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.Zip")[0].style.borderColor = "#ced4da";

            }
            if (country == "") {
                document.getElementsByName("OrdersModel.Country")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.Country")[0].style.borderColor = "#ced4da";

            }
            if (phone == "") {
                document.getElementsByName("OrdersModel.Phone")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.Phone")[0].style.borderColor = "#ced4da";

            }
            if (email == "" || validateEmail(email) != true) {
                document.getElementsByName("OrdersModel.Email")[0].style.borderColor = "#ff4545";
            } else {
                document.getElementsByName("OrdersModel.Email")[0].style.borderColor = "#ced4da";

            }

            toastr["warning"]("Údaje nie sú vyplnené alebo sú vyplnené nesprávne.");
            toastr.options = {
                "closeButton": true,
                "debug": false,
                "newestOnTop": false,
                "progressBar": false,
                "positionClass": "toast-top-right",
                "preventDuplicates": false,
                "onclick": null,
                "showDuration": "300",
                "hideDuration": "1000",
                "timeOut": "5000",
                "extendedTimeOut": "1000",
                "showEasing": "swing",
                "hideEasing": "linear",
                "showMethod": "fadeIn",
                "hideMethod": "fadeOut"
            }
            return false;
        }
    }
}

function validateEmail(email) {
    var re = /\S+@\S+\.\S+/;
    return re.test(String(email).toLowerCase());
}