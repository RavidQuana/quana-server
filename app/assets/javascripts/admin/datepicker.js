$(document).ready(function () {
    $.datepicker.setDefaults({
        dateFormat: "<%= I18n.t('datepicker.format') %>"
    });

    $.datetimepicker.setLocale('he');

    $('.date-time-picker').datetimepicker({});
});