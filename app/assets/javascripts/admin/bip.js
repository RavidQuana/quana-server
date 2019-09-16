$(document).on('best_in_place:error', function (event, request, error) {
    // Display all error messages from server side validation
    response = $.parseJSON(request.responseText);
    $.each(response, function (index, value) {
        if (value.length > 0) {
            if (typeof(value) == "object") {
                value = value.toString();
            }
            var container = $("<span class='flash-error'></span>").html(value);
            container.purr();
        }
        ;
    });
});

$(document).ready(function () {
    $('.best_in_place').best_in_place();
});