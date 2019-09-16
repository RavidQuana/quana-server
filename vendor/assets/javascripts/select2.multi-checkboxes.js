/**
 * jQuery Select2 Multi checkboxes
 * - allow to select multi values via normal dropdown control
 * 
 * author      : wasikuss
 * inspired by : https://github.com/select2/select2/issues/411
 * License     : MIT
 */
 
(function($) {
  $.fn.extend({
    select2MultiCheckboxes: function() {
      var options = $.extend({
        closeOnSelect: false, 
        templateResult: function(item) {
          var $r = $('<div>').text(item.text).addClass('option-wrap');

          if (item.element) {
            if ($(item.element).hasClass('checked')) {
              $r.addClass('checked');
            }
          }

          return $r;
        }        
      }, arguments[0]);

      this.each(function() {
        var $s2 = $(this).select2(options);

        function setLabel() {
          var options = $(this).data('select2').options.options;

          var template = options.labelTemplate;
          var itemsCount = $(this).select2('data').length;
          var $label = $(this).siblings('span.select2').find('ul');

          if (itemsCount !== 0) {
            $label.html('<li class="select2-selection__choice">' + 
              template.replace('%{count}', itemsCount) + '</li>');
          }
        }

        $s2.data('select2').$container.addClass('s2-checkboxes');
        $s2.data('select2').$dropdown.addClass('s2-checkboxes');

        $s2.on('select2:select', function(e) {
          $(e.params.data.element).addClass('checked');
          $('#' + e.params.data._resultId + ' .option-wrap').addClass('checked');
        });

        $s2.on('select2:unselect', function(e) {
          $(e.params.data.element).removeClass('checked');
          $('#' + e.params.data._resultId + ' .option-wrap').removeClass('checked');
        });

        $s2.on('select2:select', setLabel);
        $s2.on('select2:unselect', setLabel);
      });
    }
  });
})(jQuery);