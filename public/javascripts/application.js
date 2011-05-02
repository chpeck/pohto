var current = null;
var angle = 0;

$(function(){
  $('img.thumbnail').mouseover(function(e) {
    e.stopPropagation();
    current = this;
  });

  $('body').mouseover(function() {
    current = null;
    $('img#medium').hide();
    $('img#medium')[0].style.width=null;
    $('img#medium')[0].style.height=null;
  });

  $('img#medium').mouseover(function(e) {
    e.stopPropagation();
    $('img#medium').show();
  });

  $(document).mousemove(function(e){
    var img = $('img#medium');
    if(current && img[0].src != current.getAttribute('data-medium')) {
      img[0].src = current.getAttribute('data-medium');
      img[0].onload = function() { 
        img.show(); 
      }
    } 
    if(img.width() == 0 || img.height() == 0) return;
    var midx = $(window).width() / 2;
    var top = e.pageY - (img.height() / 2);
    if (top < $(window).scrollTop()) top = $(window).scrollTop();
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
  }).keyup(function(e) {
    if(e.keyCode == 82 || e.keyCode == 76) {
      if(e.keyCode == 82) {
        angle += 90;
      }
      if(e.keyCode == 76) {
        angle -= 90;
      }
      if(angle < 0) angle = 360 + angle;
      angle = angle % 360;
      $('img#medium').rotate(angle);
    }
    if(e.keyCode == 68) {
      if(current) window.location = 'photos/' + current.getAttribute('id');
    }
  }); 
});
