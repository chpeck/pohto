// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(function(){
  $('img.thumbnail').hover(function() {
    var img = $('img#medium')[0];
    if(img.src == this.getAttribute('data-medium')) {
      $(img).show();
      return;
    }
    img.src = this.getAttribute('data-medium');
    img.onload = function() { $(this).show(); };
  }, function() {
    $('img#medium').hide();
  });

  $(document).mousemove(function(e){
    var img = $('img#medium')[0];
    img.style.top = 10 + $(window).scrollTop() + 'px';
    img.style.left = e.pageX + 'px';
  }); 
});
