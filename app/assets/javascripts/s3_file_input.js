const KB = 1024;
const MB = 1024 * KB;
const MAX_FILESIZE = 10 * MB;

const STRINGS = {
	upload_failed: 'File upload failed!',
	file_size_too_big: 'Maximum allowed file size: ' + MAX_FILESIZE + '.'
}

const S3_OPTION_KEYS = [
	'key', 
	'acl', 
	'policy',
	'success-action-status',
	'x-amz-credential', 
	'x-amz-algorithm', 
	'x-amz-date', 
	'x-amz-signature'
];

var uploadedFiles = 0;
var submittedFiles = 0;

function buildFormData(data) {
	return Object.keys(data).map(function(key, index) {
    	return {
      		name: key,
      		value: data[key]
    	};
  	});
}

function buildThumbnail(data, fileName, contentType) {
	if (contentType.includes('image')) {
		return $("<img class='s3-thumb' src='" + data + "' />");
	} else if (contentType.includes('video')) {
		return $("<video class='s3-thumb' src='" + data + "' />");
	}

	return $("<div class='s3-thumb'>" + fileName + "</div>");
}

function buildPreview(file, $container) {
	var fileName = file.name;
	var contentType = file.type;
	var reader = new FileReader();
	
	reader.readAsDataURL(file);
	reader.onload = function (e) {
		var data = e.target.result;

		var $thumbnail = buildThumbnail(data, fileName, contentType);
		var $preview = $(
			"<div class='s3-file-preview' data-file='" + fileName + "' >" +
				"<div class='s3-overlay'></div>" +
				"<progress value='0' max='100' class='s3-progress'></progress>" +
			"</div>"
		);
		$preview.append($thumbnail);
		$container.append($preview);
    }	
}

function validateSize(file) {
	if (file.size > MAX_FILESIZE) {
		Swal.fire({
		  type: 'error',
		  title: STRINGS.upload_failed,
		  text: STRINGS.file_size_too_big,
		})

		return false;
	}	

	return true;
}

function validateContentType(file) {
	return true;
}

function initS3FileInput($input) {
	var formData = { };
	var $container = $input.closest('.input');

	var s3_options = S3_OPTION_KEYS.reduce(function(obj, key) { 
		if (key !== 'success-action-status') {
			obj[key] = $input.data(key);	
		}
		return obj;
	}, {});
	s3_options['content-type'] = ''; 
	s3_options['success_action_status'] = '201';

	$input.fileupload({
		paramName: 'file',
		autoUpload: false,
		url: $input.data('url'),
		replaceFileInput: false,
		singleFileUploads: true,
		add: function(e, data) {
			var files = data.files;

			// clear existing previews
	        $('.s3-file-preview', $container).remove();

	        // run validations & build new preview
			for (var i = 0, len = files.length; i < len; i++) {
				var file = files[i];

				file.id = Math.random().toString(36).substr(2, 16);

				if (!validateSize(file) || !validateContentType(file)) {
					$input.val(null);
					return;					
				}

				buildPreview(file, $container);
			}

          	// postpone form submission until all files have been uploaded to S3
			$('input[type="submit"]').bind('click', function(event) {
				event.preventDefault();
				data.submit();
				submittedFiles++;
				return false
			});						
		},
		formData: function(form) {
			var file = this.files[0];
	    	var id = file.id;

	    	formData[id] = {
	    		...s3_options,
	    		'content-type': file.type
	    	};

	    	return buildFormData(formData[id]);
		},
		progress: function(e, data) {
			var file = data.files[0];
			var fileName = file.name;
			var progress = parseInt(data.loaded / data.total * 100, 10);

			var $target = $(e.target);
			var $preview = $('.s3-file-preview[data-file="' + fileName + '"]', $container);
			var $progressBar = $('.s3-progress', $preview);

	        $progressBar.prop('value', progress);
	    },
	    done: function(e, data) {
			uploadedFiles++;

	    	// after the upload has been completed, update the relevant inputs with the S3 file keys
	     	var $keysInput = $('.s3-file-keys', $container);
	     	var isArray = $container.hasClass('s3_array');

	     	var file = data.files[0];
	     	var fileName = file.name;
	     	var key = $input.data('key').split('/').slice(-1)[0].replace('${filename}', fileName);

	     	$currentKeys = $keysInput.val();
	     	if ($currentKeys && isArray) {
	     		$keysInput.val($currentKeys + ',' + key);	
	     	} else {
	     		$keysInput.val(key);
	     	}

			var $form = $container.closest('form');
			$input.remove();

			 // check that all files have been uploaded, then submit the form 
			 // using either submit (for standard forms) or rails-ujs (for ajax)
	      	if (uploadedFiles === submittedFiles) {
				if ($form.data('remote')) {
					Rails.fire($form[0], 'submit');
				} else {
					$form.submit();
				}
	      	}
	 	}
 	});	
}

$(document).ready(function() {

	// init file uploader
	$('.s3_file input').each(function() { initS3FileInput($(this)); });
	$('.s3_array input').each(function() { initS3FileInput($(this)); });
	
	$(document).on('DOMNodeInserted', function(e) {
	   	var  $inputs = $(e.target).find('.s3-input-wrapper input');
		if ($inputs.length) { $inputs.each(function() { initS3FileInput($(this)); }); }
	});

	// handle image removal
	$('.s3-clear').on('click', function() {
		var $container = $(this).closest('.input');
		var $keysInput = $('.s3-file-keys', $container);
		var currentKeys = $keysInput.val().split(',');
		
		// remove key from set and update hidden input value
		currentKeys.splice(currentKeys.indexOf($(this).data('key')), 1);
		$keysInput.val(currentKeys.join(','));
		$(this).parent().remove();
	});	
});