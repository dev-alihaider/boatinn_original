if (window.location.hash === '#_=_') window.location.hash = '';

$(document).ready(function() {

  $(document).mouseup(function (e) {
    var container = $(".user-menu");
    if (!(container.parent().find(".name").is(e.target) || container.parent().find(".avatar img").is(e.target)) && container.has(e.target).length === 0){
      container.siblings().removeClass("active");
    }
  });

  $('#current_currency').on('change', function () {
    $.ajax({
      url: '/api/set_current_currency.json',
      method: 'PATCH',
      async: false,
      data: {
        currency: $(this).val()
      },
      success: function () {
        location.reload(true);
      },
      error: function (error) {
        console.log(error);
      }
    });
  });

  $('.user-panel a.nav-anchor').click(function(e){
    e.preventDefault();
    $(this).toggleClass("active");
    if($(".btn-mobile-nav-switch").hasClass('active')) {
      $(".btn-mobile-nav-switch").removeClass('active');
      $(".toplinks").slideUp();
    };
  });

  //Button for Go Back
  $('#btn-go-back').on('click', function(e){
    e.preventDefault();
    history.back();
  });

  //Button for Print
  $('.btn-print').on('click', function(e){
    e.preventDefault();
    window.print();
  });

  //Init Select2
  $('.select2').select2({
    minimumResultsForSearch: -1
  });

  // Init Slick
  $('.home-slider').slick({
    autoplay: true,
    arrows: false,
    autoplaySpeed: 5000
  });

  // Init Datepicker
  $('.datepicker').datepicker({
    format: 'yyyy-mm-dd',
    autoclose: true
  });

  // Init Datepicker Couple
  var dateCoupleFrom = $('.datepicker-couple.couple-from');
  var dateCoupleTo = $('.datepicker-couple.couple-to');
  dateCoupleFrom.datepicker({
    format: 'yyyy-mm-dd',
    autoclose: true,
    startDate: new Date()
  });
  dateCoupleTo.datepicker({
    format: 'yyyy-mm-dd',
    autoclose: true,
    startDate: new Date()
  });
  dateCoupleFrom.on('changeDate', function() {
    dateCoupleTo.val('');
    var tesr = dateCoupleFrom.datepicker('getDate');
    //tesr.setDate(tesr.getDate()+1); //shift to one day
    dateCoupleTo.datepicker('setStartDate', tesr);
  });

  //Language Switch
  $(document.body).on("change", '#language', function(){
    $(location).attr('href', $(this).find('option:selected').attr('data-url'));
  });

  //Clear input-error
  $('body').on('focus', '.input-error', function() {
    $(this).removeClass('input-error');
    $(this).parent().find('.field-error').detach();
  });

  //Clear select-error
  $('body').on('change', 'select.input-error', function() {
    if($(this).val() != '') {
      $(this).removeClass('input-error');
      $(this).parent().find('.field-error').detach();
    }
  });

  // Reviews slider
  $('.reviews-slider').slick({
    dots: true,
    arrows: true,
    customPaging: function(slick,index) {
      return '<span>' + (index + 1) + '</span>';
    }
  });   

  //Mobile menu switcher
  $('.btn-mobile-nav-switch').on('click', function(){
    if(!$(this).hasClass('active')) {
      $(this).addClass('active');
      $(".toplinks").slideDown();
    } else {
      $(this).removeClass('active');
      $(".toplinks").slideUp();
    }
  });

  // $('.slider').slick();
  var length = $('.slick-slide:not(".slick-cloned")').length - 1;
  // console.log(length);

  $('.first').on('click', function(){
    $('.reviews-slider').slick('slickGoTo', 0);
  });

  $('.last').on('click', function(){
    $('.reviews-slider').slick('slickGoTo', length);
  });

  // for any form switch action and method by button attributes
  $("form[action='/']").each(function(){
      $(this).find("button[data-path]").click(function(){
          var form = $(this).parents("form");
          form.attr('action', $(this).data('path'));
          form.attr('method', $(this).data('method'));
      });
  });

  // datepicker listing
  // $('.input-daterange input').each(function() {
  //   $(this).datepicker();
  // });

  if($('.passengers-input').length) {
    $('.passengers-input').styler();
  }

  $('.message-action').on('click', 'button#switch_message_form', function() {
    $(this).parent('div').find('.message-form').fadeToggle();
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

  //Global validation for numbers input
  $('input[type="number"]').on('change', function(){
    if (/\D/g.test(this.value)) {
      this.value = this.value.replace(/\D/g, '');
    }
  })
  $('input[type="number"]').on('wheel', function(e){
    e.preventDefault();
    // if (/\D/g.test(this.value)) {
    //   this.value = this.value.replace(/\D/g, '');
    // }
  });

  /// Tooltip listing page
  $('.service-fee').on('mouseenter', '.tooltip-trigger', function(event) {
    event.preventDefault();
    $(this).parents('div').find('.tooltip').fadeIn();
  }).on('mouseout', '.tooltip-trigger', function(event) {
    event.preventDefault();
    $(this).parents('div').find('.tooltip').fadeOut();
  });  

  /* global ajax navigation */
    init_ajax_pagination($(document));

  /* wizard page handler */
  $('.breadcrumbs-list .breadcrumbs-item').first().addClass('active');
  $("#btn_cancel_booking_reason").click(function(e){
    e.preventDefault();
    var $textarea = $("#cancel_reason");
    if ($textarea.val().length < 2) {
      if(($textarea.parent().find('.field-error').length == 0)) {
        $textarea.parent().append('<span class="field-error">Please write a cancellation reason</span>');
      };
      $textarea.addClass('input-error');
    } else {
      $textarea.siblings('.field-error').detach();
      $textarea.removeClass('input-error');
      var wizard = $(this).parents(".tr-wizard-step");
      wizard.hide().next().show();
      var activeLink = $('.breadcrumbs-item.active');
      activeLink.next().addClass('active');
    }
  });

  $(".next-booking-wizard").click(function(e){
    e.preventDefault();
    $("html, body").animate({ scrollTop: 0 }, "slow");
    var wizard = $(this).parents(".tr-wizard-step");
    wizard.hide().next().show();
    var activeLink = $('.breadcrumbs-item.active');
    activeLink.next().addClass('active');
  });

    var hide = true;
    $('body').on("click", function () {
        if (hide) $('.new-message-link').removeClass('opened');
        hide = true;
    });

    // add and remove .active
    $('body').on('click', '.dropdown-messages', function () {
        $('.new-message-link').addClass('opened');
        hide = false;
    });

    // add and remove .active
    $('body').on('click', '.new-message-link', function () {

        var self = $(this);

        if (self.hasClass('opened')) {
            $('.new-message-link').removeClass('opened');
            return false;
        }

        self.toggleClass('opened');
        hide = false;
    });

    // load more reviews
    $("#load-reviews-more").click(function(e){
        e.preventDefault();
        $(this).attr('disabled', true);
        var total_pages = parseInt($(this).data('pages'));
        var next_page = parseInt($(this).attr('data-current-page')) + 1;
        var url = ($(this).data('path')|| window.location) + '?page=' + next_page;
        var button = $(this);
        $.get(url, function(response){
            $("#reviews-items").append(response);
            button.attr('data-current-page', next_page);
            console.log(total_pages);
            console.log(next_page);
            if (next_page === total_pages) {
                button.remove();
            } else {
                button.removeAttr('disabled', false);
            }
        });
    });

  // Public Reply
  $(".btn-public-reply").on("click", function(e){
    e.preventDefault();
    $(".send_to_" + $(this).data('review')).slideDown();
  });
  $('.btn-cancel').on('click', function(e){
    e.preventDefault();
    $(this).parents('.send_reply').slideUp();
  });

  // Cookie Consent
  window.addEventListener("load", function(){
    window.cookieconsent.initialise({
    "theme": "classic",
    "position": "bottom-left",
    "content": {
      "message": $("#cc-text-message").val(),
      "dismiss": $("#cc-text-dismiss").val(),
      "link": $("#cc-text-link").val(),
      "href": "/poc-" + $("#language").val() + ".pdf"
    }
  })});

});/* end document ready */

// Sticky Header
$(window).scroll(function () {
  if($('body').hasClass('homepages') || $('body').hasClass('prewizards')) {
    var header = $('header');
    if($(window).width() >= 768) {
      var _height = header.height();
    } else {
      var _height = 0;
    }
    if ($(this).scrollTop() > _height && !header.hasClass('sticky') && $(window).width() > 769) {
      header.addClass('sticky');
     } else if ( $(this).scrollTop() <= header.height() ) {
      header.removeClass('sticky');
    }
  }
});

// Sticky sidebar
$(window).on('scroll', function(event){

  if($('.footer').length != 0) {

    var scrollTop = $(window).scrollTop();
    var footerTopPos = $('.footer').offset().top;
    var footerHeight = $('.footer').outerHeight();

    var stop = footerTopPos - footerHeight - 400;

    var headerHeight = $('.header').outerHeight();

    if(scrollTop >= headerHeight && scrollTop < stop) {
      $('.faq-page').addClass('fixed');
    } else {
      $('.faq-page').removeClass('fixed');
    }

    if(scrollTop >= stop) {
      $('.faq-page').addClass('absolute');
    } else {
      $('.faq-page').removeClass('absolute');
    }
  }
});

function init_ajax_pagination(container) {
    container.find(".remote-links[data-target] a").click(function(e){
        e.preventDefault();
        var target = $(this).parents('.remote-links[data-target]').data('target');
        var target_container = $(target);
        var link = $(this).attr('href');
        $.get(link, function(response){
            target_container.html(response);
            init_ajax_pagination(target_container);
        });
    });
}

