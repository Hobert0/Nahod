//Filter
var filteredData;

$(document).ready(function () {
    filteredData = allproductsdata.slice();
});

$(".productfilter").change(function (e) {
    var filteredData = allproductsdata.slice();

    let dropdownValTyp = $('#Typ').val();
    let dropdownValVyrobca = $('#Vyrobca').val();
    let price = $('#ex3').val().split(',');
    let skladom = $('#skladom');
    let novinky = $('#novinky');
    let vypredaj = $('#vypredaj');
    let akcie = $('#akcie');

    if (typeof dropdownValTyp === "undefined") {
        dropdownValTyp = "";
    }

    if (typeof dropdownValVyrobca === "undefined") {
        dropdownValVyrobca = "";
    }

    let minPrice = price[0];
    let maxPrice = price[1];

    if (dropdownValTyp != "") {
        var i = filteredData.length;
        while (i--) {

            $thisType = JSON.parse(filteredData[i].type);

            if (jQuery.inArray(parseInt(dropdownValTyp), $thisType) === -1) {
                filteredData.splice(i, 1);
            }
        }
    }

    if (dropdownValVyrobca != "") {
        var i = filteredData.length;
        while (i--) {
            if (filteredData[i].custom3 != dropdownValVyrobca) {
                filteredData.splice(i, 1);
            }
        }
    }

    if (skladom.is(":checked")) {
        var i = filteredData.length;
        while (i--) {
            if (filteredData[i].stock <= 0) {
                filteredData.splice(i, 1);
            }
        }
    }

    if (vypredaj.is(":checked")) {
        var i = filteredData.length;
        while (i--) {
            if (!filteredData[i].recommended) {
                filteredData.splice(i, 1);
            }
        }
    }

    if (akcie.is(":checked")) {
        var i = filteredData.length;
        while (i--) {
            if (filteredData[i].discountprice == null) {
                filteredData.splice(i, 1);
            }
        }
    }

    if (novinky.is(":checked")) {
        var i = filteredData.length;
        while (i--) {
            let dt = filteredData[i].date.replace(" ", "").replace(" ", "").replace(".", "-").replace(".", "-");
            dt = dt.substring(0, dt.length - 9);//datum pridania + 10 dni
            var splited = dt.split('-');
            var datetoTransform = splited[2] + "-" + splited[1] + "-" + splited[0]
            var pridaneDna = Date.parse(datetoTransform);
            var date = new Date(pridaneDna )
            date.setDate(date.getDate() + 10);

            if (date <= Date.now()) {
                filteredData.splice(i, 1);
            }
        }
    }

    var p = filteredData.length;
    while (p--) {
        let priceToCompare = filteredData[p].price;
        if (filteredData[p].discountprice != null && filteredData[p].discountprice != "") {
            priceToCompare = filteredData[p].discountprice;
        }

        if (!between(priceToCompare , minPrice, maxPrice)) {
            filteredData.splice(p, 1);
        }
    }
    
    if(allproductsdata.length != filteredData.lenght) {
    	$('#resetfilter').show();
    }else{
		$('#resetfilter').hide();
    }

    renderProducts(undefined, undefined, filteredData, undefined, false);
});

$("#sortbyprice").click(function (e) {
    var url = new URL(window.location.href);
    page = url.searchParams.get("page") ?? 1;
    localStorage.setItem('sorted', true);

    $('#resetfilter').show();

    renderProducts(page, undefined, filteredData, undefined, false);
});


$("#resetfilter").click(function (e) {
    localStorage.removeItem('sorted');
    location.reload();
});


function between(x, min, max) {
    x = parseFloat(x);
    min = parseFloat(min);
    max = parseFloat(max);

    return x >= min && x <= max;
}
