//= require arctic_admin/base
//= stub jquery_ujs
//= require rails-ujs
//= require underscore

//= require sweetalert2.all.min.js

//= require best_in_place
//= require jquery.purr
//= require best_in_place.jquery-ui

//= require uri.min
//= require select2
//= require select2.multi-checkboxes
//= require select2_input
//= require select2_locale_he

//= require jquery-fileupload/basic
//= require s3_file_input

//= require active_admin_datetimepicker

//= require admin/rtl
//= require admin/flash
//= require admin/forms
//= require admin/datepicker
//= require admin/bip
//= require admin/validations
//= require active_admin_scoped_collection_actions
//= require chartkick
//= require Chart.bundle
//= require redirect


$(function () {
    $('.download-trigger').click(function (e) {
        var data = JSON.parse($(this).attr("data"));
        var url = window.location.pathname + '/batch_action' + window.location.search

        var gdata = $('#main_content form').serializeArray().reduce(function (obj, item) {
            if (item.name[item.name.length - 2] == "[" && item.name[item.name.length - 1] == "]") {
                if (obj[item.name])
                    obj[item.name].push(item.value);
                else
                    obj[item.name] = [item.value]
            } else {
                obj[item.name] = item.value;
            }
            return obj;
        }, {});


        form_data = {
            collection_selection: [],
            authenticity_token: data.auth_token,
            batch_action: data.batch_action,
            'collection_selection[]': gdata['collection_selection[]']
        }
        $.redirect(url, form_data);
    })
});