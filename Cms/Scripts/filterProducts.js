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

    let minPrice = price[0];
    let maxPrice = price[1];

    if (dropdownValTyp != "") {
        var i = filteredData.length;
        while (i--) {
            if (filteredData[i].type != dropdownValTyp) {
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