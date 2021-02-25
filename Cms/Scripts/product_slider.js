$(document).ready(function () {
    $('.customer-logos').slick({
        slidesToShow: 4,
        slidesToScroll: 2,
        autoplay: true,
        autoplaySpeed: 3000,
        arrows: true,
        dots: false,
        pauseOnHover: false,
        responsive: [{
            breakpoint: 1024,
            settings: {
                slidesToShow: 3
            }
        },{
			breakpoint: 767,
			settings: {
				slidesToShow: 2
			}
		}, {
            breakpoint: 420,
            settings: {
                slidesToShow: 1
            }
        }]
    });
});
