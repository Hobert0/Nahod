var interval_id = 0;

$(document).ready(function () {
    // Handler for .ready() called.
    keepSessionAlive();
});

$(window).focus(function () {
    // do what you need
    if (interval_id < 1) {
        keepSessionAlive();
        interval_id++;
    }
});

$(window).blur(function () {
    clearInterval(interval_id);
    interval_id = 0;
});

function setHeartbeat() {
    setTimeout("keepSessionAlive()", 5 * 60 * 1000); // every 5 min
}

function keepSessionAlive() {
    /* RETRIEVE*/
    var retrievedObject = localStorage.getItem('addtocart');
    var jsonObj = JSON.parse(retrievedObject);

    var result = Object.keys(jsonObj).map(function (key) {
        return jsonObj[key];
    });

    $.ajaxSetup({ async: false });
    $.post("/cartsession", $.param({ cartValues: JSON.stringify(result) }, true));

    $.get(
        "/keepsessionalive",
        null,
        function (data) {
            //$("#heartbeat").show().fadeOut(1000); // just a little "red flash" in the corner :)
            setHeartbeat();
        },
        "json"
    );
}