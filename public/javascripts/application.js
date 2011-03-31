// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(function(){
  $('img.thumbnail').hover(function() {
    var img = $('img#medium')[0];
    img.src = this.getAttribute('data-medium');
    img.onload = function () { $('img#medium').show() };
  }, function() {
    $('img#medium').hide();
  });

  $(document).mousemove(function(e){
    var img = $('img#medium');
    if(img.width() == 0 || img.height() == 0) return;
    var midx = $(window).width() / 2;
    var top = e.pageY - (img.height() / 2);
    if (top < 0) top = 0;
    if (top + img.height() > $(window).scrollTop() + $(window).height()) {
      top = $(window).scrollTop() + $(window).height() - img.height() - 10;
    }
    if(e.pageX < midx) {
      left = e.pageX + 10;
      if (left + img.width() > $(window).width()) {
        img.css({width: $(window).width() - left + 5});
      }
      img.css({top: top, left: left});

    } else {
      var left = e.pageX - img.width() - 20;
      if (left < 0) { 
        left = 0;
        img.css({width: e.pageX - 20});
      }
      img.css({top: top, left: left});
    } 
  }); 
});
