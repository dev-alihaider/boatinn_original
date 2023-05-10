//= require ../application

$(document).ready(function() {

  //faq accordion
  $('.accordion').on('click', '.accordion-btn', function(){

    var elem = $(this).parents('.accordion-item');
    elem.toggleClass('active');
    
    if(elem.has('active')) {
      elem.siblings().removeClass('active');
    }
  });


  var smoothScroll = (function(){
    var anchor, sectionId, speed;
    
    return {
      onClick: function(setParent, setAnchor) {
        $(setParent).on('click', setAnchor, function(event){
          event.preventDefault();
          $(this).parent().addClass('active').siblings().removeClass('active');
          
          sectionId = $(this).attr('href');
          if(sectionId.length) {
            smoothScroll.scrollToSection(sectionId);
          }
        })
      },
      scrollToSection: function(sectionId) {
        if ($(sectionId).length) {
          if($('.faq-page').hasClass('fixed')) {
            $('html, body').animate({
              scrollTop: $(sectionId).offset().top - 110
            }, speed);
          } else {
            $('html, body').animate({
              scrollTop: $(sectionId).offset().top - 235
            }, speed);
          }
        }
      },
      init: function(setParent, setAnchor, setSpeed){
        anchor = setAnchor;
        parent = setParent;
        speed = setSpeed;
        
        this.onClick(anchor);
      }
    }
  })();

  smoothScroll.init('.accordion-item','.accordion-link', 1000);

  function scrollToAnotherSection() {

    var locationHash = location.hash;
    var section = $(locationHash);
    var activeAccordionLink = $('.accordion').find('a[href="' + locationHash +'"]');

    if (section.length) {
      window.scrollTo(0, 0);
      if(activeAccordionLink.length) {
        activeAccordionLink.parent('li').siblings().removeClass('active').parents('.accordion-item').removeClass('active');
        activeAccordionLink.parent('li').addClass('active').parents('.accordion-item').addClass('active');
        
        if($('.faq-page').hasClass('fixed')) {
          $("html, body").animate({
                scrollTop: section.offset().top - 110
            },500
          );
        } else {
          $("html, body").animate({
                scrollTop: section.offset().top - 235
            },500
          );
        }
      }
    }
  }

  setTimeout(scrollToAnotherSection(), 6000);

});