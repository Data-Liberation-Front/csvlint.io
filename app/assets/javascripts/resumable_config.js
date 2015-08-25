//= require jquery
//= require resumable

(function( jQuery ) {
  var r = new Resumable({
    target:'/api/photo/redeem-upload-token',
    query:{upload_token:'my_token'}
  });
  // Resumable.js isn't supported, fall back on a different method
  if(!r.support) location.href = '/some-old-crappy-uploader';
}( jQuery ));
