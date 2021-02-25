//Filter
var filteredData;

$(document).ready(function () {
    filteredData = allproductsdata.slice();
});

$(".productfilter").change(function (e) {
    var filteredData = allproductsdata.slice();

    let dropdownValTyp = $('#Typ').val();
    let dropdownValVyrobca = $('#Vyrobca').val();
    let kW = $('#ex1').val().split(',');
    let m2 = $('#ex2').val().split(',');
    let price = $('#ex3').val().split(',');

    let minKw = kW[0];
    let maxKw = kW[1];

    let minM2 = m2[0];
    let maxM2 = m2[1];

    let minPrice = price[0];
    let maxPrice = price[1];

    if (dropdownValTyp != "") {
        var i = filteredData.length;
        while (i--) {
            if (filteredData[i].custom8 != dropdownValTyp) {
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

    var d = filteredData.length;
    while (d--) {
        if (!between(filteredData[d].custom9.replace(",", "."), minKw, maxKw)) {
            filteredData.splice(d, 1);
        }
	}

	var o = filteredData.length;
	while (o--) {
        if (filteredData[o].custom10 != null) {
            if (!between(filteredData[o].custom10.replace(",", "."), minM2, maxM2)) {
                filteredData.splice(o, 1);
            }
        }
    }

    var p = filteredData.length;
    while (p--) {
        let priceToCompare = filteredData[p].price.replace(",", ".");
        if (filteredData[p].discountprice != null && filteredData[p].discountprice != "") {
            priceToCompare = filteredData[p].discountprice.replace(",", ".");
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

    renderProducts(undefined, undefined, filteredData, false);
});

$("#sortbyprice").click(function (e) {
    var url = new URL(window.location.href);
    page = url.searchParams.get("page") ?? 1;
    localStorage.setItem('sorted', true);

    $('#resetfilter').show();

    renderProducts(page, undefined, filteredData, false);
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