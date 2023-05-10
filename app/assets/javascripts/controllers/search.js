//= require ../application

var delay = (function(){
  var timer = 0;
  return function(callback, ms){
    clearTimeout (timer);
    timer = setTimeout(callback, ms);
  };
})();

$(document).ready(function() {


 function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
    var expires = "expires="+d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
  }

  function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i = 0; i < ca.length; i++) {
      var c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
        return c.substring(name.length, c.length);
      }
    }
    return "";
  }

  function checkCookie() {
    var user = getCookie("showexprience");
    if (user != "") {
    } else {
       if (mobile == 0){
           // Show modal
          // $('#myModal').modal('show');
         setCookie("showexprience", "yes", 365);
       }
    }
  }

 checkCookie();
 
 $('#location').on('change', function(){
    if($(this).val() === '') {
      $('#lat-value').val('');
      $('#lng-value').val('');
    };
  });

  $('#location').keypress(function(e) {
    if(e.keyCode === 13){
      e.preventDefault();
      if($('#location').val() === '') {
        $('#lat-value').val('');
        $('#lng-value').val('');
      };

      delay(function(){
        var inputLocation = $('.search-form #location'),
            startPHLocation = $('#location').prop('placeholder'),
            emptyLocation = 'Select location from dropdown list';

        if($('#lat-value').val() === '' && !($('#location').hasClass('.input-error'))) {
          inputLocation.prop('placeholder', emptyLocation);
          var firstResult = $(".pac-container .pac-item:first .pac-item-query").text();
          inputLocation.val(firstResult);
          $('.search-form').submit();
        } else {
          inputLocation.removeClass('input-error');
          inputLocation.prop('placeholder', startPHLocation);
          $('.search-form').submit();
        };
      }, 500);
    }
  });

  // Tabs
  $('.filters-nav a').on('click', function(e){
    e.preventDefault();
    if($(this).hasClass('active')) {
      $('.search-filter-box').hide();
      $(this).removeClass('active');
    } else {
      $(this).addClass('active');
      $(this).parent().siblings().find('a').removeClass('active');
      $('.search-filter-box').hide();
      $($(this).attr('href')).show();
    }
  });
  $('.btn-filter-close').on('click', function(e){
    e.preventDefault();
    $(this).parents('.search-filter-box').hide();
  });

  // Adding to Wishlist
  if($('#current-user-id').length != 0) {
    var userId = $('#current-user-id').val();
  };
  $('.search-results').on('click', '.wishlist-add', function(e){
    e.preventDefault();
    var listingId = $(this).data('id');
    var messageText = $('#title-add-wishlist').val();
    var ajaxType = 'POST';
    var ajaxData = { id: listingId };
    var ajaxUrlFragment = '';

    if($(this).hasClass('active')) {
      ajaxType = 'DELETE';
      ajaxData = {};
      ajaxUrlFragment = '/' + listingId;
      messageText = $('#title-delete-wishlist').val();
    }
    $.ajax({
      type: ajaxType,
      dataType: 'json',
      data: ajaxData,
      url: '/api/users/' + userId + '/wishlist' + ajaxUrlFragment + '.json',
      error: function (error) { console.log(error); }
    });
    $(this).toggleClass('active');
    $(this).find('i').toggleClass('fa-heart-o').toggleClass('fa-heart');
    displayFlashMessage(messageText);
  });

  // Ajax Filter and Pagination
  var currentPage = 1;
  var s_pagination = $('#search-pagination');
  var s_results = $('#search-results');
  var s_defaultOpts = {
    totalPages: 6,
    visiblePages: 6,
    first: '<span aria-hidden="true"><small>|</small>&lsaquo;</span>',
    prev: '<span aria-hidden="true">&lsaquo;</span>',
    next: '<span aria-hidden="true">&rsaquo;</span>',
    last: '<span aria-hidden="true">&rsaquo;<small>|</small></span>'
  };

  if($('#pagination_total_pages').val() > 1) {
    s_pagination.twbsPagination($.extend({}, s_defaultOpts, {
      startPage: 1,
      totalPages: $('#pagination_total_pages').val(),
      initiateStartPageClick: false,
      onPageClick: function(event, page) {
        currentPage = page;
        listingsFiltering(page, undefined, true);
      }
    }));
  };

  // General variables
  var minPrice = Math.round($('#min-price-1').val()),
      maxPrice = Math.round($('#max-price-1').val()),
      sliderCurrency = $('#slider-currency').val(),
      searchSlider = $("#search-slider-range"),
      shared_number_of_seats_text = $('#shared-number-of-seats-text').val();
      per_night_text = $('#per-night-text').val();

  function listingsFiltering(pagenumber, changeRental, shiftPriceChecking) {

    if(pagenumber !== undefined) {
      currentPage = pagenumber;
    } else {
      currentPage = 1;
    };

    var changeRental = changeRental,
        shiftPriceChecking = shiftPriceChecking;

    // If change type rental => delete value to min max inputs for all results
    if(changeRental) {
      $('#min-price-value').val('');
      $('#max-price-value').val('');
    };

    var minPrice = $('#min-price-value').val(),
        maxPrice = $('#max-price-value').val(),
        boatTypes = [],
        boatExper = [],
        rentalType,
        withCaptain,
        checkInDate = $('#from').val(),
        checkOutDate = $('#to').val(),
        passengersCount = $('#passengers').val(),
        perPage = 12, //Configure count listings for one page
        latValue = $('#lat-value').val(),
        lngValue = $('#lng-value').val(),
        typeRental,

        minPriceServer,
        maxPriceServer,
        searchSlider = $("#search-slider-range"),
        sliderCurrency = $('#slider-currency').val();


    $('#type_boat input[type="checkbox"]:checked').each(function(){
      boatTypes.push($(this).data('type'));
    });

    rentalType = $('#type_rental input[type="radio"]:checked').data('rental');

    $('#experience input[type="checkbox"]:checked').each(function(){
      boatExper.push($(this).data('exp'));
    });

    if($('#filter_captain input#captain_with').prop('checked')) {
      withCaptain = $('#filter_captain input#captain_with').val();
    } else if ($('#filter_captain input#captain_without').prop('checked')) {
      withCaptain = $('#filter_captain input#captain_without').val();
    };

    typeRental = $('#type_rental input[type="radio"]:checked');

    $.ajax({
      type: 'GET',
      dataType: 'json',
      data: {
        min_price: minPrice,
        max_price: maxPrice,
        boat_types: boatTypes,
        rental_type: rentalType,
        experiences: boatExper,
        with_captain: withCaptain,
        check_in_date: checkInDate,
        check_out_date: checkOutDate,
        passengers_count: passengersCount,
        per_page: perPage,
        page: currentPage,
        lat: latValue,
        lng: lngValue
      },
      url: '/api/boats.json',
      cache: false,
      beforeSend: function(){
        s_results.addClass('wait');
      },
      success: function(data) {
        var items = [],
            locations = [],
            wishBox,
            priceBox;

        // Load and build results
        $.each(data.boats, function(key, val) {
          if($('#current-user-id').length !== 0) {
            if(val.wished == false) {
              wishBox = '<a class="wishlist-add" href="#" data-id="' + val.id + '"><i class="fa fa-heart-o"></i></a>';
            } else if(val.wished == true) {
              wishBox = '<a class="wishlist-add active" href="#" data-id="' + val.id + '"><i class="fa fa-heart"></i></a>';
            };
          } else {
            wishBox = '';
          }

          // First var
          // if (typeRental.data('rental') == 1) {
          //   priceBox = '<div class="price price-classic"><div class="price-number">' + val.prices.per_half_day + '</div><div class="price-per">Per half day</div></div>';
          // } else if (typeRental.data('rental') == 2) {
          //   priceBox = '<div class="price price-boatshared"><div class="price-number">' + val.prices.shared_price + '</div><div class="price-per">Per person</div></div> <div class="pas-count"><i class="fa fa-user"></i>' + val.passengers_count + '<p>number of seats</p></div>';
          // } else if (typeRental.data('rental') == 3) {
          //   priceBox = '<div class="price price-sleeping"><div class="price-number">' + val.prices.sleepin_per_night + '</div><div class="price-per">Per night</div></div>';
          // };

          // Second var
          // priceBox = '<div class="price">' +
          //   '<span class="price-number">' + val.minimum_rental.price + '</span> /'
          //   + val.minimum_rental.rental;

          //   if (typeRental.data('rental') == 2) {
          //     priceBox += '<div class="pas-count1">' +
          //       '<i class="fa fa-user"></i> ' + val.minimum_rental.passengers +
          //       '<span> ' + shared_number_of_seats_text + '</span></div>'
          //   }

          // priceBox += '</div>';

          // Final var
          if (typeRental.data('rental') == 1) {
            typeRental_t='classic'
            priceBox = '<div class="price price-classic">' +
                         '<span class="price-number">' +
                           val.minimum_rental.price + 
                         '</span> /' +
                         val.minimum_rental.rental + 
                       '</div>';          
          } else if (typeRental.data('rental') == 2) {
            typeRental_t='shared'
            priceBox = '<div class="price price-boatshared">' + 
                         '<div class="price-number">' + 
                           val.prices.shared_price + 
                         '</div>' +
                         '<div class="pas-count1">' +
                           '<i class="fa fa-user"></i> ' + 
                           val.minimum_rental.passengers +
                           '<span> ' + shared_number_of_seats_text + '</span>' +
                         '</div>' +
                       '</div>';
          } else if (typeRental.data('rental') == 3) {
            typeRental_t='sleepin'
            priceBox = '<div class="price price-sleeping">' +
                         '<span class="price-number">' +
                           val.prices.sleepin_per_night + 
                         '</span> /' +
                         per_night_text + 
                       '</div>';
          };

          //Check url val from ajax data
          if(val.url.indexOf('?') != -1){
             typeRental_f= '&startRentalType=' +typeRental_t;
          } else {
             typeRental_f= '?startRentalType=' +typeRental_t;
          }

          items.push('<div class="search-result-box">' +
            '<div class="img-wrap">' +
              '<a href="' + val.url + typeRental_f + '" target="_blank">' +
                '<img src="' + val.image + '" alt="' + val.listing_title+ ' pcr ' + val.url  + '">' +
              '</a>' +
              wishBox +
            '</div>' +
            '<div class="inf-wrap">' +
              '<div class="title">' +
                '<a href="' + val.url + typeRental_f + '" target="_blank">' +
                  val.listing_title +
                '</a>' +
              '</div>' +
              priceBox +
              '<div class="location">' +
                '<i class="fa fa-map-marker"></i>' +
                val.location.name +
              '</div>' +
              '<div class="custom-design-var-2">' +
                '<div class="rating-wrapper">' +
                  '<div class="rating">' +
                    '<div class="rating-full" style="width:' + (val.rating.avg/5*100) + '%;">' +
                      '<i class="fa fa-star"></i>' +
                      '<i class="fa fa-star"></i>' +
                      '<i class="fa fa-star"></i>' +
                      '<i class="fa fa-star"></i>' +
                      '<i class="fa fa-star"></i>' +
                    '</div>' +
                    '<div class="rating-empty">' +
                      '<i class="fa fa-star-o"></i>' +
                      '<i class="fa fa-star-o"></i>' +
                      '<i class="fa fa-star-o"></i>' +
                      '<i class="fa fa-star-o"></i>' +
                      '<i class="fa fa-star-o"></i>' +
                    '</div>' +
                  '</div>' +
                  '<div class="review-count">' +
                    "(" + val.rating.count + ")" +
                  '</div>' +
                '</div>' +
              '</div>' +
            '</div>' +
          '</div>');
          if(val.location.lat !== null) {
            locations.push({lat: +val.location.lat, lng: +val.location.lng});
          }
        });
        s_results.empty().prepend(items.join(""));

        if(locations.length !== 0) {
          initMap(locations);
        } else {
          initMap([]);
        }

        // Update pagination
        var totalPages = data.pagination.total_pages;
        //var currentPaget = s_pagination.twbsPagination('getCurrentPage');
        var currentPaget = data.pagination.current_page;
        s_pagination.twbsPagination('destroy');
        if(totalPages > 1) {
          s_pagination.twbsPagination($.extend({}, s_defaultOpts, {
            startPage: currentPaget,
            totalPages: totalPages,
            initiateStartPageClick: false,
            onPageClick: function(event, page) {
              currentPage = page;
              $(window).scrollTop(0);
              listingsFiltering(page, undefined, true);
            }
          }));
        };

        // If was rental type changing
        if(changeRental !== undefined) {
          if(changeRental) {
            // Update price slider
            minPriceServer = Math.round(data.prices.minimum);
            maxPriceServer = Math.round(data.prices.maximum);
            searchSlider.slider('option', "values", [minPriceServer, maxPriceServer]);
            searchSlider.slider('option', 'min', minPriceServer);
            searchSlider.slider('option', 'max', maxPriceServer);
            if (minPriceServer === maxPriceServer) {
              searchSlider.addClass('disabled');
            } else {
              searchSlider.removeClass('disabled');
            };
            $('.ui-slider-handle:first .price-count').html(minPriceServer + '<span class="search-currency">' + sliderCurrency + '</span>');
            $('.ui-slider-handle:last .price-count').html(maxPriceServer + '<span class="search-currency">' + sliderCurrency + '</span>');
            $('#min-price-value').val(minPriceServer);
            $('#max-price-value').val(maxPriceServer);
          }
        } else {
          console.log('rental undefined');
        };

        // If change price NOT with slider AND with min=max => disable slider
        // Must be refactore
        if(!shiftPriceChecking) {
          if(data.pagination.total_count === 1) {
            minPriceServer = Math.round(data.prices.minimum);
            maxPriceServer = Math.round(data.prices.maximum);
            searchSlider.slider('option', "values", [minPriceServer, maxPriceServer]);
            searchSlider.slider('option', 'min', minPriceServer);
            searchSlider.slider('option', 'max', maxPriceServer);
            $('.ui-slider-handle:first .price-count').html(maxPriceServer + '<span class="search-currency">' + sliderCurrency + '</span>'); // min == max, if results == 1
            $('.ui-slider-handle:last .price-count').html(maxPriceServer + '<span class="search-currency">' + sliderCurrency + '</span>');
            searchSlider.addClass('disabled');
          } else if(data.pagination.total_count === 0) {
            minPriceServer = 0;
            maxPriceServer = 0;
            searchSlider.slider('option', "values", [minPriceServer, maxPriceServer]);
            searchSlider.slider('option', 'min', minPriceServer);
            searchSlider.slider('option', 'max', maxPriceServer);
            $('.ui-slider-handle:first .price-count').html(minPriceServer + '<span class="search-currency">' + sliderCurrency + '</span>');
            $('.ui-slider-handle:last .price-count').html(maxPriceServer + '<span class="search-currency">' + sliderCurrency + '</span>');
            searchSlider.addClass('disabled');
          } else {
            minPriceServer = Math.round(data.prices.minimum);
            maxPriceServer = Math.round(data.prices.maximum);
            searchSlider.slider('option', 'min', minPriceServer);
            searchSlider.slider('option', 'max', maxPriceServer);
            $('.ui-slider-handle:first .price-count').html(minPriceServer + '<span class="search-currency">' + sliderCurrency + '</span>');
            $('.ui-slider-handle:last .price-count').html(maxPriceServer + '<span class="search-currency">' + sliderCurrency + '</span>');
            searchSlider.slider('option', "values", [minPriceServer, maxPriceServer]);
            searchSlider.removeClass('disabled');
          }
        };

      },
      error: function (error) {
        console.log(error);
      },
      complete: function(){
        s_results.removeClass('wait');
      }
    });

  };

  var rentalText;

  function rentalTextSwitchering(){
    rentalText = $('#type_rental input[type="radio"]:checked').siblings().text();
    $('.rent-type-text').text(rentalText);

    // if(rentalText.length !== 0) {
    //   $('.rent-type-text').show().text(rentalText);
    // } else {
    //   $('.rent-type-text').hide();
    // };
  };

  rentalTextSwitchering();

  $('.btn-apply-filters').on('click', function(e){
    e.preventDefault();

    // Check switch typre rental
    if($(this).parents('.search-filter-box').hasClass('type_rental-filter')) {
      listingsFiltering(undefined, true, false);
    } else {
      listingsFiltering(undefined, false, false);
    };

    rentalTextSwitchering();

    $(this).parents('.search-filter-box').hide();
    $('.filters-nav').find('.active').removeClass('active');

    // $('#min-price-value-base').text(minPriceDB + '€');
    // $('#max-price-value-base').text(maxPriceDB + '€');

    searchUpdateDate();
  });

  var dateCoupleFrom = $('#from');
  var dateCoupleTo = $('#to');

  function dateToUpdate() {
    //listingsFiltering();
    //what is this? we have two ajax requests :(

    var typeRentalVal = $('#type_rental input[type="radio"]:checked').data('rental');

    if(typeRentalVal == 2) {
      checkOutDate = dateCoupleFrom.datepicker('getDate');
      var newDate = new Date(checkOutDate);

      dateCoupleTo.datepicker("setDate", checkOutDate);
      dateCoupleTo.datepicker("setStartDate", checkOutDate);
      dateCoupleTo.datepicker("update", checkOutDate);

      $('#to').attr('disabled', 'disabled');
    } else {
      $('#to').removeAttr('disabled');
    }
  }

  function searchUpdateDate() {
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
    dateCoupleFrom.on('changeDate', function(){
      dateToUpdate();
    });
    dateToUpdate();
  }

  // Validation of search-form
  var startPHLocation = $('#location').prop('placeholder'),
      emptyLocation = 'Select location from dropdown list',

      startPHFrom = $('#from').prop('placeholder'),
      emptyFrom = 'Select date',

      startPHTo = $('#to').prop('placeholder'),
      emptyTo = 'Select date';

  function locateValidation(){
    var inputLocation = $('.search-form #location');
        inputFrom = $('.search-form #from');
        inputTo = $('.search-form #to');

    if($('#lat-value').val() == '' && !($('#location').hasClass('.input-error'))) {
      inputLocation.addClass('input-error');
      inputLocation.val('');
      inputLocation.prop('placeholder', emptyLocation);
    } else {
      inputLocation.removeClass('input-error');
      inputLocation.prop('placeholder', startPHLocation);
    };

    // if(inputFrom.val() == '') {
    //   if(!inputFrom.hasClass('input-error')) {
    //     inputFrom.addClass('input-error');
    //   };
    //   inputFrom.prop('placeholder', emptyFrom);
    // } else {
    //   inputFrom.removeClass('input-error');
    //   inputFrom.prop('placeholder', startPHFrom);
    // };

    // if(inputTo.val() == '') {
    //   if(!inputTo.hasClass('input-error')) {
    //     inputTo.addClass('input-error');
    //   };
    //   inputTo.prop('placeholder', emptyTo);
    // } else {
    //   inputTo.removeClass('input-error');
    //   inputTo.prop('placeholder', startPHTo);
    // };

    if($('.search-form .input-error').length == 0) {
      listingsFiltering();
    }
  };

  $('.search-form button[type="submit"]').on('click', function(e){
    e.preventDefault();
    locateValidation();
  });

  // Price Range
  searchSlider.slider({
    range: true,
    min: minPrice,
    max: maxPrice,
    values: [ minPrice, maxPrice ],
    create: function() {

      $('.ui-slider-handle:first').html('<span class="price-count left">' + $("#search-slider-range").slider("values", 0) + '<span class="search-currency">' + sliderCurrency + '</span>' + '</span>');
      $('.ui-slider-handle:last').html('<span class="price-count right">' + $("#search-slider-range").slider("values", 1) + '<span class="search-currency">' + sliderCurrency + '</span>' + '</span>');

      // Disable slider, if max == min
      if (minPrice === maxPrice) {
        searchSlider.addClass('disabled');
      };
      if (minPrice < 0){
	    minPrice = 0;
      };
      // if(minPrice === maxPrice){
      //   $('.ui-slider-handle:first').html('<span class="price-count left">' + $("#search-slider-range").slider("values", 1) + '<span class="search-currency">' + sliderCurrency + '</span>' + '</span>');
      //   // ToDO: Find out from Vanya why slider initializing two times, one time is here and another time is in filter
      //   // For now I have add a dirty huck - added class and in css rewrite with !important
      //   $('.ui-slider-handle').addClass('left-by-force');
      //   console.log('minPrice === maxPrice');
      // } else {
      //   $('.ui-slider-handle:first').html('<span class="price-count left">' + $("#search-slider-range").slider("values", 0) + '<span class="search-currency">' + sliderCurrency + '</span>' + '</span>');
      //   $('.ui-slider-handle:last').html('<span class="price-count right">' + $("#search-slider-range").slider("values", 1) + '<span class="search-currency">' + sliderCurrency + '</span>' + '</span>');
      // }

      //$('#min-price-value').val($("#search-slider-range").slider("values", 0));
      //$('#max-price-value').val($("#search-slider-range").slider("values", 1));
      //$('#min-price-value-base').text($("#search-slider-range").slider("values", 0) + sliderCurrency);
      //$('#max-price-value-base').text($("#search-slider-range").slider("values", 1) + sliderCurrency);
    },
    slide: function(event, ui) {
      $('.ui-slider-handle:first .price-count').html(ui.values[0] + '<span class="search-currency">' + sliderCurrency + '</span>');
      $('.ui-slider-handle:last .price-count').html(ui.values[1] + '<span class="search-currency">' + sliderCurrency + '</span>');
      $('#min-price-value').val(ui.values[0]);
      $('#max-price-value').val(ui.values[1]);
    },
    stop: function(event, ui) {
      listingsFiltering(undefined, undefined, true);
    }
  });

  // Switcher type rental
  // $('#type_rental input[type="radio"]').on('change', function(){

  //   var minPriceDB = Math.round($('#min-price-' + $(this).data('rental')).val());
  //   var maxPriceDB = Math.round($('#max-price-' + $(this).data('rental')).val());
  //   searchSlider.slider('option', 'min', minPriceDB);
  //   searchSlider.slider('option', 'max', maxPriceDB);
  //   $('.ui-slider-handle:first .price-count').text(minPriceDB + '€');
  //   $('.ui-slider-handle:last .price-count').text(maxPriceDB + '€');
  //   $('#min-price-value').val(minPriceDB);
  //   $('#max-price-value').val(maxPriceDB);
  //   $('#min-price-value-base').text(minPriceDB + '€');
  //   $('#max-price-value-base').text(maxPriceDB + '€');

  //   if($(this).data('rental') == 1) {
  //     $('.price').hide();
  //     $('.price.price-classic').show();
  //   } else if($(this).data('rental') == 2) {
  //     $('.price').hide();
  //     $('.price.price-boatshared').show();
  //   } else if($(this).data('rental') == 3) {
  //     $('.price').hide();
  //     $('.price.price-sleeping').show();
  //   };

  // });

  if(window.window.innerWidth < 770) {
    $(".search-sidebar").insertAfter(".filter-price");
  };
 
  // Reload price with radio filter selected
  listingsFiltering(undefined, true, false); 										  
												


});
