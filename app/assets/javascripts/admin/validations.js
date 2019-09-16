function verifyLimit(e) {
    var $wrapper = $(this).parent('.input');

    var l = $(this).val().length + 1;
    var max = $wrapper.data('maxlength');

    if (l > max && !(e.keyCode === 8 || e.keyCode === 46)) {
        return false;
    }
}

function updateIndicator(e) {
    var $wrapper = $(this).parent('.input');

    var l = $(this).val().length;
    var max = $wrapper.data('maxlength');

    if (l <= max) {
        $wrapper.attr('data-length-indicator', l + '/' + max);
    }
}

function verifyInteger(e) {
    var charCode = (e.which) ? e.which : e.keyCode;

    if (charCode > 31 && (charCode < 48 || charCode > 57))
        return false;

    return true;
}

function verifyDecimal(e) {
    var charCode = (e.which) ? e.which : e.keyCode;
    var dotCount = ($(this).val().match(/\./g) || []).length;

    if (charCode != 46 && charCode > 31
        && (charCode < 48 || charCode > 57)) {
        return false;
    } else {
        return charCode != 46 || (charCode == 46 && dotCount < 1);
    }
}

$(document).ready(function () {
    $(document).on('keypress', '.limited input', verifyLimit);
    $(document).on('keyup', '.limited input', updateIndicator);
    $(document).on('keydown', '.limited input', updateIndicator);
    $('.limited input').each(updateIndicator);

    $(document).on('keypress', '.integer', verifyInteger);
    $(document).on('keypress', '.decimal', verifyDecimal);
});