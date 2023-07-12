function validateForm() {
    var condition = document.getElementById("condition2");

    var username = document.getElementById("userEmail").value;
    var name = document.getElementsByName("UsersmetaModel.Name")[0].value;
    var surname = document.getElementsByName("UsersmetaModel.Surname")[0].value;
    var address = document.getElementsByName("UsersmetaModel.Address")[0].value;
    var city = document.getElementsByName("UsersmetaModel.City")[0].value;
    var zip = document.getElementsByName("UsersmetaModel.Zip")[0].value;
    var country = document.getElementsByName("UsersmetaModel.Country")[0].value;
    var phone = document.getElementsByName("UsersmetaModel.Phone")[0].value;

    if (!passwordCheck()) {
        return false;
    }

    if (name !== "" && surname !== "" && address !== "" && city !== "" && zip !== "" && country !== "" && phone !== "" && username !== "" && validateEmail(username) === true) {
        if (condition.checked === true) {
            if (!checkUsername(username)) {
                document.getElementById("emailexist").style = "display: block;";
                return false;
            } else {
                document.getElementById("emailexist").style = "display: none;";
            }
            $("#regheader").submit();
        } else {
            document.getElementById("conditioncheck2").style.border = "1px solid #ff4545";
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
            document.getElementsByName("UsersmetaModel.Name")[0].style.borderColor = "#ff4545";
        } else {
            document.getElementsByName("UsersmetaModel.Name")[0].style.borderColor = "#ced4da";
        }
        if (surname == "") {
            document.getElementsByName("UsersmetaModel.Surname")[0].style.borderColor = "#ff4545";
        } else {
            document.getElementsByName("UsersmetaModel.Surname")[0].style.borderColor = "#ced4da";

        }
        if (address == "") {
            document.getElementsByName("UsersmetaModel.Address")[0].style.borderColor = "#ff4545";
        } else {
            document.getElementsByName("UsersmetaModel.Address")[0].style.borderColor = "#ced4da";

        }
        if (city == "") {
            document.getElementsByName("UsersmetaModel.City")[0].style.borderColor = "#ff4545";
        } else {
            document.getElementsByName("UsersmetaModel.City")[0].style.borderColor = "#ced4da";

        }
        if (zip == "") {
            document.getElementsByName("UsersmetaModel.Zip")[0].style.borderColor = "#ff4545";
        } else {
            document.getElementsByName("UsersmetaModel.Zip")[0].style.borderColor = "#ced4da";

        }
        if (country == "") {
            document.getElementsByName("UsersmetaModel.Country")[0].style.borderColor = "#ff4545";
        } else {
            document.getElementsByName("UsersmetaModel.Country")[0].style.borderColor = "#ced4da";

        }
        if (phone == "") {
            document.getElementsByName("UsersmetaModel.Phone")[0].style.borderColor = "#ff4545";
        } else {
            document.getElementsByName("UsersmetaModel.Phone")[0].style.borderColor = "#ced4da";

        }
        if (username === "" || validateEmail(username) !== true) {
            document.getElementById("userEmail").style.borderColor = "#ff4545";
        } else {
            document.getElementById("userEmail").style.borderColor = "#ced4da";
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
        };
        return false;
    }

}

function checkUsername(email) {
    var bool = false;
    $.ajax({
        type: "POST",
        url: 'Admin/EmailExist',
        async: false,
        data: { email: email },
        success: function (response) {
            //call is successfully completed and we got result in data
            if (response.success) {
                // success code here
                bool = true;
            } else {
                // error code here
                bool = false;
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            //some errror, some show err msg to user and log the error  
        }
    });
    return bool;
}

function validateEmail(email) {
    var re = /\S+@\S+\.\S+/;
    return re.test(String(email).toLowerCase());
}

function passwordCheck() {
    var heslo = document.getElementById("heslo").value;
    var overheslo = document.getElementById("overheslo").value;

    if (heslo !== overheslo) {
        document.getElementById("alert").style = "display: block;";
        return false;
    } else {
        document.getElementById("alert").style = "display: none;";
        if (heslo.length < 8) {
            document.getElementById("tooshort").style = "display: block;";
            return false;
        } else {
            document.getElementById("tooshort").style = "display: none;";
        }
        return true;
    }
}

function validateEmailaddress() {
    var email = document.getElementById("subscriberEmail").value;

    if (validateEmail(email)) {
        document.getElementById("wrongemail").style = "display: none;";
        return true;
    } else {
        document.getElementById("wrongemail").style = "display: block;";
        return false;
    }
}