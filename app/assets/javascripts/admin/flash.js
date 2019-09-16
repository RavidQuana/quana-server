$(document).on('DOMNodeInserted', function (e) {
    var $target = e.target;
    if (e.target.attr && e.target.attr('class') == 'flash') {
        $target.velocity('fadeIn', {
            delay: 250, duration: 1500, complete: function () {
                $target.velocity('fadeOut', {delay: 4500, duration: 1500});
            }
        });
    }
});

$(document).on('click', '.flash .close', function () {
    var $flash = $(this).parent();
    $flash.velocity('stop', true);
    $flash.velocity('fadeOut', {duration: 1500});
});