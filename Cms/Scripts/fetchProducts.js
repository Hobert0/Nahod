var allproductsdata;
var allvariants;

$(document).ready(function () {
    var url = new URL(window.location.href);
    page = url.searchParams.get("page") ?? 1;
    bybrand = url.pathname.includes("znacka") ?? false;
    bytype = url.pathname.includes("typ") ?? false;
    search = url.pathname.includes("vyhladavanie") ?? false;
    fetchProducts(page, bybrand, search, bytype);
});

function fetchProducts(page, bybrand, search, bytype) {
    let params = window.location.pathname.split('/');
    let catslug = params[2];
    let subslug = params[3];
    let subslug2 = params[4];
    let subslug3 = params[5];
    let brand = false;
    let type = false;
    let searchparam = false;
    let APIurl = "/Api/FetchProducts";
    if (bybrand) brand = true;
    if (search) searchparam = true;
    if (bytype) type = true;

    var $loading = "<div class='loading' style='text-align:center;margin-top:100px;'><img style='width:100px;' src='/Uploads/loading.gif'></div>";
    $('#ajaxProducts').prepend($loading);
    $.ajax({
        url: APIurl,
        type: 'GET',
        async: false,
        data: { catslug: catslug, subslug: subslug, subslug2: subslug2, subslug3: subslug3, brand: brand, searchparam: searchparam, type: type },
        dataType: 'json',
        success: function (data) {
            allproductsdata = data.data;
            allvariants = data.variants;
            renderProducts(page, undefined, allproductsdata, allvariants);
        },
        error: function () {
            alert('Error! Please try again.');
        }
    }).done(function () {
        //$loading.remove();
    });

}

function fetchUser(username, id) {    
    let APIurl = "/Api/FetchUser";

    $.ajax({
        url: APIurl,
        type: 'GET',
        async: false,
        data: { username: username, userid: id },
        dataType: 'json',
        success: function (data) {
            userdata = data.data;
        },
        error: function () {
        }
    }).done(function () {
        //$loading.remove();
    });
    return userdata;
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

function renderProducts(page = 1, pagesize = 20, alldata = allproductsdata, vars = allvariants, pagechanged = false) {

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

    var $container = $('<div id="productsblock"/>').addClass('row products-row m-0');

    $.each(productsdata, function (i, item) {
        var variants = vars.filter(element => element.prod_id == item.id);
        var slug = string_to_slug(item.title);
        var variableproduct = "false";
        var isvariablecolor = "false";
        var isDiscounted = false;
        let username = document.getElementById('userName');
        let userid = document.getElementById('userId');
        let exist = null;
        let rating = 0;

        if (username != null && userid != null) {
            exist = fetchUser(username.value, userid.value);
        }


        if (item.custom4 != null && item.custom4 != "") {
            variableproduct = "true";
        }
        if (item.custom7 != null) {
            isvariablecolor = "true";
        }

        if (variants.length > 0) {
            $.each(variants, function (i, item) {
                if (item.discountprice != null) {
                    isDiscounted = true;
                }
            });
        }
        else {
            if (item.discountprice != null) {
                isDiscounted = true;
            }
        }

        let $row = '<div class="col-md-5ths product mb-2 mx-1">';

        $row += '<a href="/detail-produktu/' + item.id + '/' + slug + '">';
        $row += '<div class="thumb" style="background-image: url(' + escape("/Uploads/" + item.image) + '); height: 11vw;background-size:contain;"></div>'

        $row += '<div class="prod-labels">';
        if (isDiscounted == true) {
            $row += '<span class="prod-discount">akcia</span>';
        }

        //zistim ci sa jedna o novinku, je starsia menej ako 10 dni
        var postedDate = Date.parse(item.date);
        var date10days = new Date();
        date10days = date10days.setDate(date10days.getDate() - 10);

        if (postedDate >= date10days) {
            $row += '<span class="prod-new">novinka</span>';
        }
        $row += '</div><div class="prod-header">' + item.title + '</div>';

        var shortdescription = "";
        if (item.description != null) {            
            shortdescription = stripHtml(item.description).substring(0, 60) + "...";
        }

        $row += '<div class="prod-text">' + shortdescription + '</div>';
        $row += '<div class="prod-prices">';

        let variantPriceFrom = 99999;
        let isVariant = "false";
        let firstAttrId = 0;

        $.each(variants, function (i, variant) {
            if (firstAttrId == 0) {
                firstAttrId = variant.attribute_id;
            }

            if (firstAttrId == variant.attribute_id) {
                if (variant.discountprice != null) {
                    if (variant.discountprice < variantPriceFrom) {
                        variantPriceFrom = variant.discountprice;
                        variantPriceFrom = variantPriceFrom.toFixedNoRounding(2);

                    }
                }
                else {
                    let thisPrice = 0;

                    //rating
                    if (username != null && userid != null) {

                        if (exist != null) {
                            rating = exist.rating;
                        }

                        let defaultPrice = variant.price;
                        let ratingPrice = 0;

                        switch (rating) {
                            case 1:
                                ratingPrice = 0.95 * defaultPrice;
                                break;
                            case 2:
                                ratingPrice = 0.9 * defaultPrice;
                                break;
                            case 3:
                                ratingPrice = 0.85 * defaultPrice;
                                break;
                        }

                        thisPrice = ratingPrice;
                    }
                    else {
                        thisPrice = variant.price;
                    }

                    if (thisPrice < variantPriceFrom) {
                        variantPriceFrom = thisPrice.toFixedNoRounding(2);
                    }
                }
            }

            isVariant = "true";
        });

        let actualPrice = 0.0;
        if (variantPriceFrom != 99999) {
            $row += '<span class="prod-price-from">od ' + variantPriceFrom.replace(".", ",") + ' €</span>';
        } else {
            //rating
            if (username != null) {

                if (exist != null) {
                    rating = exist.rating;
                }

                let defaultPrice = item.price;
                let ratingPrice = 0;

                switch (rating) {
                    case 1:
                        ratingPrice = 0.95 * defaultPrice;
                        break;
                    case 2:
                        ratingPrice = 0.9 * defaultPrice;
                        break;
                    case 3:
                        ratingPrice = 0.85 * defaultPrice;
                        break;
                }

                $row += '<span class="prod-discount">' + defaultPrice.replace(".",",") + ' €</span> <span class="prod-base">' + ratingPrice.toFixedNoRounding(2) + ' €</span>';
                actualPrice = ratingPrice;
            }
            else {
                $row += '<span class="prod-base">' + item.price.toFixedNoRounding(2).replace(".", ",") + ' €</span>';
                actualPrice = item.price;
            }
        }    

        $row += '</div></a>';
        let actualPriceStr = actualPrice.toFixedNoRounding(2);
        $row += '<a onclick="addToCart(' + item.id + ',' + isVariant + ',' + actualPriceStr + ')" class="prod-add-to-cart"><div style="text-align: center;"> <img class="prod-icon" src="/Content/images/cart.svg" alt="cart"><span>Pridať do košíka</span></span></div>';

        
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
        $pages += '<li class="page-item"><a class="page-link" onclick="renderProducts(' + (page - 1) + ', undefined, undefined, undefined, true)" aria-label="Previous"><span aria-hidden="true">&laquo;</span><span class="sr-only">Previous</span></a></li>';
    }

    for (i = 1; i <= totalPages; i++) {
        let active = "";
        if (i == page) { active = "active"; }
        $pages += '<li class="page-item ' + active + '"><a class="page-link" onclick="renderProducts(' + i + ', undefined, undefined, undefined, true)">' + i + '</a></li>';
    }

    if (totalPages > 1 && totalPages > page) {
        $pages += '<li class="page-item"><a class="page-link" onclick="renderProducts(' + (page + 1) + ', undefined, undefined, undefined, true)" aria-label="Next"><span aria-hidden="true">&raquo;</span><span class="sr-only">Next</span></a></li>';
    }

    $pages = $($pages);

    $('#pagination').html($pages);
}

function stripHtml(html) {
    let tmp = document.createElement("DIV");
    tmp.innerHTML = html;
    return tmp.textContent || tmp.innerText || "";
}



