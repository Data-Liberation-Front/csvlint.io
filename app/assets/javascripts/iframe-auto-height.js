
$(document).ready(function () {
	$('.article-sidebar iframe, .grid iframe').iframeAutoHeight({
		animate: true,
		callback: function (callbackObject) { 
			$('.grid').masonry();
		},
		triggerFunctions: [
			function (resizeFunction, iframe) {
				$(window).resize(function () {
					resizeFunction(iframe);
				});
			}
		]
	});
});
