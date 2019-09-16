$(document).ready(function() {
	// patch form actions to add locale
	$('form').each(function() {
		var action = $(this).attr('action');
		$(this).attr('action', action.replace('/<%= I18n.default_locale %>/', '/<%= I18n.locale %>/'));
	});

	// remove language from breadcrumbs
	$('.breadcrumb a').first().remove();
	$('.breadcrumb .breadcrumb_sep').first().remove();

	// patch sidebar toggle
	$('#sidebar').off('click');
  	$('#sidebar').click(function (e) {
    	var position = $(this).position();
    	var width = $(this).width();
    	if (e.pageX > Math.ceil(position.left) + width) {
    		if (Math.ceil(position.left) == 0) {
      		$(this).css('position', 'fixed');
      		$(this).animate({
        			left: "-=" + width
      		}, 600, function() {
        			animationFilterDone = true;
      		});
    		} else {
      		$(this).animate({
        			left: "+=" + width
      		}, 600, function() {
        			$(this).css('position', 'absolute');
        			animationFilterDone = true;
      		});
    		}
    	}
  	});

  	// patch mobile menu toggle
  	var animationDone = true;
  	$('#utility_nav').off('click');
	  $('#utility_nav').click(function (e) {
    	var position = $(this).position();
    	var tabs = $('#tabs');
    	var width = Math.ceil(tabs[0].getBoundingClientRect().width);

    	if (e.pageX < (Math.ceil(position.left) + 40)) {
      		if (animationDone == true) {
        		animationDone = false;
	        	if (tabs.css('left') == '0px') {
	          		tabs.animate({
	          		  	left: "-="+width
	          		}, 400, function() {
	            		animationDone = true;
	          		});
	        	} else {
	          		tabs.animate({
	            		left: "+="+width
	          		}, 400, function() {
	            		animationDone = true;
	          		});
	        	}
      		}
    	}
  	}); 	 	
});