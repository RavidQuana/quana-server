'use strict';

function d2IndexOf(array, item) {
  for (var i = 0; i < array.length; i++) {
    if (array[i][0] == item[0] && array[i][1] == item[1]) {
      return i;
    }
  }
  return -1;
}

function initSelect2(inputs) {
  return inputs.each(function() {
    var item, options;
    item = $(this);  

    options = $.extend({
      width: 'resolve',
      dropdownParent: item.data('dropdownparent') != undefined ? $(item.data('dropdownparent')) : $('body')
    }, item.data('select2'));

    // add support for custom templates
    if (options.templateResult) {
      var fn = window[options.templateResult];

      if (typeof fn === 'function') {
        options.templateResult = fn;
      } else {
        delete options.templateResult;
      }
    }

    if (options.templateSelection) {
      var fn = window[options.templateSelection];

      if (typeof fn === 'function') {
        options.templateSelection = fn;
      } else {
        delete options.templateSelection;
      }
    }

    // handle dependencies using dynamic ajax urls
    var hasDependencies = item[0].dataset.dependencies;
    if (hasDependencies) {
      var baseUri = item.data('select2').ajax.url;
      var dependencies = JSON.parse(item[0].dataset.dependencies);

      options.ajax.url = function() {
        var ajaxUri = new URI(baseUri);
        
        for (var d in dependencies) {
          var dependency = dependencies[d];

          var uriSearch = {};
          var key = dependency.key;
          var field = dependency.field || 'id';
          var values = _.map($(dependency.source).select2("data"), function(v){ return v[field]; });
          var value = values.length > 1 ? values : values[0];
          uriSearch[key] = value;
          ajaxUri.addSearch(uriSearch); 
        }

        return ajaxUri.toString();
      };

      // check for required dependencies and disable select when needed
      var requiredDependencies = 0;

      for (var d in dependencies) {
        var dependency = dependencies[d];
        var $source = $(dependency.source);

        if (dependency.required) { 
          if ($source.val() == '') { requiredDependencies++ };

          $source.on('select2:selecting', function(e) { 
            $(this).attr('data-prev-value', $(this).val());
          });

          $source.on('select2:select select2:unselect', function(e) {   
            var locks = parseInt(item.attr('data-required-dependencies'), 10) || 0;

            if (e.type == 'select2:select') {
              if ($(this).attr('data-prev-value') === '') {
                item.attr('data-required-dependencies', --locks);   
              }
            } else {
              item.attr('data-required-dependencies', ++locks);
            }
            
            item.prop('disabled', locks !== 0);
            if (item.val() !== '') { item.val('').trigger('change').trigger('select2:unselect') };   
          });
        }
      }

      item.attr('data-required-dependencies', requiredDependencies); 
      item.prop('disabled', requiredDependencies > 0);
      if (requiredDependencies > 0) { item.val('').trigger('change') }
    }

    item.data('select2', null);

    // patch old multiple select2 delete behavior (allow tag removal on backspace)
    $.fn.select2.amd.require(['select2/selection/search'], function (Search) {
      var oldRemoveChoice = Search.prototype.searchRemoveChoice;
        
      Search.prototype.searchRemoveChoice = function () {
        oldRemoveChoice.apply(this, arguments);
        this.$search.val('');
      };

      // add support for checkboxes on multiple select
      if (item.hasClass('s2-checkboxes') && item.attr('multiple')) {
        item.select2MultiCheckboxes(options);
      } else {
        item.select2(options); 
      }        
    });

    // handle group select
    item.on("select2:selecting", function(e) {
      var $selectedItem = e.params.args.data;
      
      if ($selectedItem.nested) {
        var childIds = [];
        e.preventDefault();

        _.each($selectedItem.nested, function(element, index, list) {
          childIds.push(element.id);
          
          if ($("option[value='" + element.id + "']", item).length == 0) {
            var opt = $('<option>' + element.text + '</option>').val(element.id);
            item.append(opt);
          }
        });

        item.val(childIds).trigger('change').select2('close');
      }
    });

    // update additional elements on select
    item.on("select2:select", function(e) {
      if (e.target.dataset.updateElements) {
        var data = e.params.data;
        var updateElements = JSON.parse(e.target.dataset.updateElements);
        for (var key in updateElements) {
          $(updateElements[key]).val(data[key]).trigger('change');
        } 
      }
    });      

    item.on("select2:unselect", function(e) {
      if (e.target.dataset.updateElements) {
        var updateElements = JSON.parse(e.target.dataset.updateElements);
        for (var key in updateElements) {
          $(updateElements[key]).val('');
        }  
      }    
    });

      // prevent opening on clear
      item.on('select2:opening', function (e) {
          if ($(this).data('unselecting')) {
              $(this).removeData('unselecting');
              if (!$(this).data('isOpen')) {
                  e.preventDefault();
              }
          }
      })
          .on('select2:unselecting', function (e) {
              $(this).data({
                  unselecting: true,
                  isOpen: $(this).data('select2').isOpen()
              });
          });

    // get value after postback
    var windowUri = new URI(window.location.href);
    var ids = windowUri.search(true)[item.attr('name')];

    if (ids) {
      if (typeof ids == "string") {
          ids = [ids];
      }
      var id;
      var element, existingElement;
      for (var i = 0; i < ids.length; i++) {
        id = ids[i];

        // check for existing option element
        existingElement = $("option[value='" +  id + "']", item);
        if (existingElement.length) {
          existingElement.attr('selected', 'selected');
          item.trigger('change');
        } else {
          // append a new selected element
          element = $('<option selected></option>').val(id);
          item.append(element).trigger('change');

          if (options.ajax) {
            $.ajax({
              type: 'GET',
              url: hasDependencies ? options.ajax.url() : options.ajax.url,
              data: { 
                term: id,
                exact_match: 'id'
              },
              dataType: 'json'
            }).then(function (data) {
              var e = $("option[value='" +  data['results'][0].id + "']", item);
              e.text(data['results'][0].text);
              e.removeData();
              item.trigger('change');
            });            
          } else {
            element.text(id);
            element.removeData();
            item.trigger('change');
          }
        }        
      } 
    }
  });
};


$(document).ready(function() {
  var $select2Inputs = $('.select2-input');
  $.each($select2Inputs, function() {
    if (!$(this).parents('.best_in_place').length) {
      initSelect2($(this));   
    }
  });

  // handle dynamic inserts
  $(document).on('DOMNodeInserted', function(e) {
    var $target = $(e.target);
    var isInPlaceInput = $target.parents('.best_in_place').length;

    if ($target.hasClass('select2-input') && !isInPlaceInput) {
      initSelect2($target); 
    }

    if ($target.children('.select2-input') && !isInPlaceInput) {
      var $select2Inputs = $('.select2-input', $target);
      $.each($select2Inputs, function() { initSelect2($(this)); });
    }
  });

  $('body').on('best_in_place:activate', '.best_in_place', function() {
    this.update = function() {};
    
    var $select2 = null;
    var $select = $(this).find('select');

    if ($select.attr('multiple')) {
      // BIP MULTI-SELECT FIX
      // all options are derived from bip-collection, which has the following format:
      // [[id1, val1], [id2, val2] ... [idn, valn], ['[id1, id2, ..., idn]', '[val1, val2, ..., valn]']]
      // where [multi-id, multi-val] is a unique dummy item required to correctly display the initial field value 
      
      // set all options as selected and remove the dummy item
      $select.find('option').prop('selected', true);
      $select.find('option').each(function() {
        if (!parseInt($(this).val(), 10)) { $(this).remove(); }
      });

      // add 'ok' button
      var $controlsWrap = $('<div class="bip-controls"></div>');
      $controlsWrap.insertAfter($select);

      var okButtonText = $(this).data('bipOkButton');

      if (okButtonText) {
        var okButtonClass = $(this).data('bipOkButtonClass') || '';
        var $okButton = $('<a href="#" class="bip-ok-button ' + okButtonClass + '">' + okButtonText + '</a>');
        $controlsWrap.append($okButton);        
      }
    
      // only submit on 'ok' (to allow multi-selection)
      $select.unbind('change');

      $okButton.on('click', { bip_element: this }, function(e) {
        e.preventDefault();

        var $bipElement = $(e.data.bip_element);
        var editor = $bipElement.data('bestInPlaceEditor');
        editor.update();      
      });

      // init select2 and handle events
      $select2 = initSelect2($select).on('select2:selecting', function(e) {
        // track item selection
        $(this).attr('data-selecting', true);

      }).on('select2:unselecting', function(e) {
        // track item removal
        $(this).attr('data-unselecting', true);

      }).on('select2:unselect', { bip_element: this }, function(e) {
        // update the bip-collection array (remove item)
        var $bipElement = $(e.data.bip_element);
        var bipCollection = $bipElement.data('bip-collection');
        var unselectedItem = [e.params.data.id, e.params.data.text];
        var unselectedItemIndex = d2IndexOf(bipCollection, unselectedItem);

        bipCollection.splice(unselectedItemIndex, 1);
        $bipElement.attr('data-bip-collection', JSON.stringify(bipCollection));

      }).on('select2:select', { bip_element: this }, function(e) {
        // update the bip-collection array (add item)
        var $bipElement = $(e.data.bip_element);
        var bipCollection = $bipElement.data('bip-collection');
        var selectedItem = [e.params.data.id, e.params.data.text];
        
        bipCollection.push(selectedItem);
        $bipElement.attr('data-bip-collection', JSON.stringify(bipCollection));

      }).on('select2:close', { bip_element: this }, function(e) {
        // abort on close (unless event is triggered by selection\removal)
        if (!($(this).data('selecting') || $(this).data('unselecting'))) {
          var $bipElement = $(e.data.bip_element);
          var editor = $bipElement.data('bestInPlaceEditor');
          editor.abort();        
        }

        // clear tracking flag (see above)
        $(this).attr('data-selecting', false); 
        $(this).attr('data-unselecting', false); 
      });      
    } else {
      // BIP SINGLE-SELECT FIX
      // clear selected option and set value to null
      $select.find('option[selected]').remove();
      $select.val(null);

      // init select2 and handle events 
      $select2 = initSelect2($select).on('select2:close', { bip_element: this }, function(e) {
        // abort on close (but only if no value has been selected yet)
        if ($(this).val() === null) {
          var $bipElement = $(e.data.bip_element);
          var editor = $bipElement.data('bestInPlaceEditor');
          editor.abort();
        }
      });
    }

    // attach 'blur' handler to bip's one
    setTimeout(function() {
      $select2.select2('open'); 
    }, 100);
    return $select2.unbind('blur').bind('blur', { editor: this }, BestInPlaceEditor.forms.select.blurHandler); 
  });
});