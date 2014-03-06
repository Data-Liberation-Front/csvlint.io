// Get Masonry layout going on any element with a class of 'grid'
$('.grid').imagesLoaded(function() {

    $('.grid').masonry({

        itemSelector: '.home-module',
        transitionDuration: 0

    });

});

// Top grid on section landing pages
if ($('#grid1').length) {

    new AnimOnScroll( document.getElementById('grid1'), {
        minDuration : 0.4,
        maxDuration : 0.7,
        viewportFactor : 0.2
    });

}

// Lower grid on section landing pages
if ($('#grid2').length) {

    new AnimOnScroll( document.getElementById('grid2'), {
        minDuration : 0.4,
        maxDuration : 0.7,
        viewportFactor : 0.2
    });

}

// Grid on people page
if ($('#grid-people').length) {

    new AnimOnScroll( document.getElementById('grid-people'), {
        minDuration : 0.4,
        maxDuration : 0.7,
        viewportFactor : 0.2
    });

}

// Remove Masonry effects on mobile
// This may need revisiting on a wider range of devices (performance tests etc.)
if (screen.width <= 1024) {

    $('.grid').removeClass('effect-2').find('li').css('opacity', '1');

}
