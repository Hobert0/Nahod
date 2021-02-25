var allproductsdata;

$(document).ready(function () {
    var url = new URL(window.location.href);
    page = url.searchParams.get("page") ?? 1;
    bybrand = url.pathname.includes("znacka") ?? false;
    search = url.pathname.includes("vyhladavanie") ?? false;
    fetchProducts(page, bybrand, search);
});

function fetchProducts(page, bybrand, search) {
    let params = window.location.pathname.split('/');;
    let catslug = params[2];
    let subslug = params[3];
    let subslug2 = params[4];
    let subslug3 = params[5];
    let brand = false;
    let searchparam = false;
    let APIurl = "/Api/FetchProducts";
    if (bybrand) brand = true;
    if (search) searchparam = true;

    var $loading = "<div class='loading' style='text-align:center;margin-top:100px;'><img style='width:100px;' src='/Uploads/loading.gif'></div>";
    $('#ajaxProducts').prepend($loading);
    $.ajax({
        url: APIurl,
        type: 'GET',
        async: false,
        data: { catslug: catslug, subslug: subslug, subslug2: subslug2, subslug3: subslug3, brand: brand, searchparam: searchparam },
        dataType: 'json',
        success: function (data) {
            allproductsdata = data.data;
            renderProducts(page, undefined, allproductsdata);
        },
        error: function () {
            alert('Error! Please try again.');
        }
    }).done(function () {
        //$loading.remove();
    });

}

function string_to_slug(str) {
    str = str.replace(/^\s+|\s+$/g, ''); // trim
    str = str.toLowerCase();

    // remove accents, swap ñ for n, etc
    var from = "àáäâèéëêìíïîòóöôùúüûñç·/_,:;";
    var to = "aaaaeeeeiiiioooouuuunc------";
    for (var i = 0, l = from.length; i < l; i++) {
        str = str.replace(new RegExp(from.charAt(i), 'g'), to.charAt(i));
    }

    str = str.replace(/[^a-z0-9 -]/g, '') // remove invalid chars
        .replace(/\s+/g, '-') // collapse whitespace and replace by -
        .replace(/-+/g, '-'); // collapse dashes

    return str;
}

function renderProducts(page = 1, pagesize = 12, alldata = allproductsdata, pagechanged = false) {

    if (page > 1) {
        window.history.pushState({}, '', '?page=' + page);

    } else {
        window.history.replaceState({}, '', window.location.pathname)
    }

    if (pagechanged) $("html").animate({ scrollTop: 0 }, "slow");

    const sorted = localStorage.getItem('sorted');
    if (sorted) {
        alldata.sort(function (a, b) {
            return a.price - b.price;
        });
        $('#resetfilter').show();
    }

    var totalRecord = Object.keys(alldata).length;
    var totalPages = (totalRecord / pagesize) + ((totalRecord % pagesize) > 0 ? 1 : 0);
    productsdata = alldata.slice((page - 1) * pagesize, pagesize * page);

    var $container = $('<div id="productsblock"/>').addClass('row py-4');

    $.each(productsdata, function (i, item) {

        var slug = string_to_slug(item.title);
        var variableproduct = "false";
        var isvariablecolor = "false";

        if (item.custom4 != null && item.custom4 != "") {
            variableproduct = "true";
        }
        if (item.custom7 != null) {
            isvariablecolor = "true";
        }

        let $row = '<div class="col-6 col-md-6 col-lg-4 productcontent">';
        $row += '<div style="overflow:hidden;">';


        $row += '<a href="/detail-produktu/' + item.id + '/' + slug + '" class="product_detail"><div class="thumb" style="background-image: url(' + escape("/Uploads/" + item.image) + '); height: 320px; background-size: contain;"></div></a>'

        if (item.price == "0") {

            if (item.custom6 != null && item.custom6 == "True") //ak je zadane ze cena je od
            {

                $row += '<a href="/detail-produktu/' + item.id + '/' + slug + '" id = "" style="cursor: pointer;" class="col-sm-2 col-4 cartproduct"> <div style="text-align: center;"><img src="/Content/images/cart_white.svg" style="width: 24px;margin-top: -4px;" alt="cart" /></div></a>';
            }
            $row += '<a href="/detail-produktu/' + item.id + '/' + slug + '" id = "" style="cursor: pointer;" class="col-sm-2 col-4 cartproduct"> <div style="text-align: center;"><img src="/Content/images/cart_white.svg" style="width: 24px;margin-top: -4px;" alt="cart" /></div></a>';
        }
        else //ak je cena v pohode
        {
            $row += '<a onclick="addToCart(' + item.id + ',' + variableproduct + ',' + isvariablecolor + ')" style="cursor: pointer;" class="col-sm-2 col-4 cartproduct"><div style="text-align: center;"><img src="/Content/images/cart_white.svg" style="width: 24px;margin-top: -4px;" alt="cart" /></div></a>';
        }
        $row += '</div>';
        $row += '<a href="/detail-produktu/' + item.id + '/' + slug + '" id = "" class="product_detail"><p class="title category" style="line-height: 18px;">' + item.title + '</p></a>';
        $row += '<div style="display: flex;"><div class="col price">';
        if (item.discountprice != "" && item.discountprice != null) {
            $row += '<span>' + parseFloat(item.discountprice).toFixed(2) + '€</span>';
            $row += '<del>' + parseFloat(item.price).toFixed(2) + '€</del>';
        }
        else {
            if (item.custom6 != null && item.custom6 == "True") {
                $row += '<span>od ' + parseFloat(item.price).toFixed(2) + '€</span>';
            }
            else {
                if (item.price == "0") {
                    $row += '<span>Cena na vyžiadanie</span>';
                }
                else {
                    $row += '<span>' + parseFloat(item.price).toFixed(2) + '€</span>';
                }
            }
        }
        $row += '</div></div>';
        $row += '</div>';
        $row = $($row)

        $container.append($row);
    });

    $('#ajaxProducts').html($container);


    renderPagination(totalPages, page);
}

function renderPagination(totalPages, page) {
    var $pages = '';
    totalPages = Math.floor(totalPages);

    if (totalPages > 1 && page > 1) {
        $pages += '<li class="page-item"><a class="page-link" onclick="renderProducts(' + (page - 1) + ', undefined, undefined, true)" aria-label="Previous"><span aria-hidden="true">&laquo;</span><span class="sr-only">Previous</span></a></li>';
    }

    for (i = 1; i <= totalPages; i++) {
        let active = "";
        if (i == page) { active = "active";}
        $pages += '<li class="page-item '+ active +'"><a class="page-link" onclick="renderProducts(' + i + ', undefined, undefined, true)">' + i + '</a></li>';
    }

    if (totalPages > 1 && totalPages > page) {
        $pages += '<li class="page-item"><a class="page-link" onclick="renderProducts(' + (page + 1) + ', undefined, undefined, true)" aria-label="Next"><span aria-hidden="true">&raquo;</span><span class="sr-only">Next</span></a></li>';
    }

    $pages = $($pages);

    $('#pagination').html($pages);
}



