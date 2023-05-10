//= require ../application

$(window).load(function() {
  // Search Bar
  if($(".slider-search-control-panel").length != 0 && $(window).width() > 769) {
    var _b_top = $(".slider-search-control-panel").parent().offset().top;
    $(document).scroll(function () {
      var _s_top = ($(document).scrollTop() + 80);
      if(_s_top > _b_top && $('.header-search-wrapper .slider-search-control-panel').length == 0){
        $('header').addClass('with-search');
        $('body').addClass('page-with-sticky-search');
        $(".slider-search-control-panel").prependTo('.header-search-wrapper');
        $(".slider-search-control-panel").removeClass('container');
      }
      if(_s_top <= _b_top && $('.slider-search-wrapper .slider-search-control-panel').length == 0){
        $('header').removeClass('with-search');
        $('body').removeClass('page-with-sticky-search');
        $(".slider-search-control-panel").appendTo('.slider-search-wrapper');
        $(".slider-search-control-panel").addClass('container');
      }
    });
  }
});
