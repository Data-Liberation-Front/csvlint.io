// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.browser
//= require jquery.iframe-auto-height
//= require iframe-auto-height
//= require bootstrap/bootstrap-dropdown.js
//= require bootstrap/bootstrap-modal.js

$('a[data-toggle=dropdown]').click(function() {
	if ($(this).next('.dropdown-menu').css('display') == "block") {
		window.location.href = this.href;
	}
});

$("#odi-logo").on("contextmenu",function(e){
    e.preventDefault()
    e.stopPropagation()
    $('#getLogo').modal()
    return false
});