//= require ../application 
//= require report_about_review

// Helpers
Date.prototype.addDays = function (days) {
  var date = new Date(this.valueOf());
  date.setDate(date.getDate() + days);
  return date;
};
function getStringDates(startDate, stopDate) {
  var dateArray = new Array();
  var currentDate = new Date(startDate);
  var stopDate = new Date(stopDate)
  while (currentDate <= stopDate) {
    var stringD = currentDate.getFullYear() + '-' +
                  String(currentDate.getMonth() + 1).replace(/^(.)$/, "0$1") + '-' + 
                  String(currentDate.getDate()).replace(/^(.)$/, "0$1");
    dateArray.push(stringD);
    currentDate = currentDate.addDays(1);
  }
  return dateArray;
};
function intersect(a, b) {
  var t;
  if (b.length > a.length) t = b, b = a, a = t; // indexOf to loop over shorter
  return a.filter(function (e) {
    return b.indexOf(e) > -1;
  });
};

// Check Dates at Array
function hasBlockedDays(start_date, end_date, array) {
  var periodDates = getStringDates(start_date, end_date);
  if (intersect(periodDates, array).length === 0) {
    return false
  } else {
    return true
  }
};

// Set options for price type select
function priceSelectUpdate(values) {
  if($('#price_type').length !== 0) {
    var $price_box = $('#price_type');
    $('#price_type option').each(function(){
      if(values.indexOf($(this).data("price-unit")) === -1) {
        $(this).attr('disabled', true);
      } else {
        $(this).attr('disabled', false);
      }
    });
    $("option[data-price-unit='" + values[0] + "']").prop("selected", true);
    $price_box.select2("destroy");
    $price_box.select2({
      minimumResultsForSearch: -1
    });
  };
};

// Init datepicker
function initCalendar(dateFrom, dateTo) {
  dateCoupleFrom = $(dateFrom); 
  dateCoupleTo = $(dateTo);
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
};

// Update datepickers values depending on the price type
function updateDate(blockedDates) {
 
  var form = $('#new-booking-form');
  var minRentalTime = form.data("min-rental-time") / 86400;
  var sleepinMinRentalTime = form.data("sleepin-min-rental-time") / 86400;

  var sleepinBlockedDates = blockedDates.booking_blocked.concat(blockedDates.sleepin_blocked);
  var classicBlockedDates = blockedDates.booking_blocked.concat(blockedDates.classic_blocked);

  var fromDate;
  if(dateCoupleFrom.datepicker('getDate')) {
    fromDate = dateCoupleFrom.datepicker('getDate');
  } else {
    fromDate = new Date();
    dateCoupleFrom.datepicker("setDate", fromDate);
  };

  var newDate = new Date(fromDate);
  var newDateStored = new Date(fromDate);
  var newDateStart = new Date(fromDate);
  if(dateCoupleTo.datepicker('getDate')) {
    newDateStored = dateCoupleTo.datepicker('getDate');
  } else {
    dateCoupleTo.datepicker("setDate", newDate);
  };
  var rental_type_shift = 0;

  var priceUnit = $("#price_type option:selected").data("price-unit");

  dateCoupleTo.datepicker("setDaysOfWeekDisabled", []);

  switch(priceUnit) {
    case "half day":
      newDate.setDate(newDate.getDate());
      break;
    case "full day":
      if (minRentalTime >= 1) {
        rental_type_shift = minRentalTime - 1;
      }
      newDate.setDate(newDate.getDate() + rental_type_shift);
      newDateStart = newDate;
      if (newDateStored > newDate) {
        newDate = newDateStored
      }
      if(minRentalTime >= 1 && hasBlockedDays(fromDate, newDate, classicBlockedDates)) {
        newDate = null;
        dateCoupleTo.datepicker("setDaysOfWeekDisabled", ['0', '1', '2', '3', '4', '5', '6']);
      };

      // if(minRentalTime < 1) {
      //   newDate.setDate(newDate.getDate());
      // } else {
      //   newDate.setDate(newDate.getDate() + (minRentalTime - 1));
      //   if(hasBlockedDays(fromDate, newDate, classicBlockedDates)) {
      //     newDate = null;
      //     dateCoupleTo.datepicker("setDaysOfWeekDisabled", ['0', '1', '2', '3', '4', '5', '6']);
      //   };
      // };
      break;
    case "night":
      if (minRentalTime > 1) {
        rental_type_shift = minRentalTime;
      } else {
        rental_type_shift = 1
      }
      newDate.setDate(newDate.getDate() + rental_type_shift);
      newDateStart = newDate
      if (newDateStored > newDate) {
        newDate = newDateStored
      }
      if(minRentalTime >= 1 && hasBlockedDays(fromDate, newDate, classicBlockedDates)) {
        newDate = null;
        dateCoupleTo.datepicker("setDaysOfWeekDisabled", ['0', '1', '2', '3', '4', '5', '6']);
      };

      // if(minRentalTime < 1) {
      //   newDate.setDate(newDate.getDate() + 1);
      // } else {
      //   newDate.setDate(newDate.getDate() + (minRentalTime));
      //   if(hasBlockedDays(fromDate, newDate, classicBlockedDates)) {
      //     newDate = null;
      //     console.log('block night');
      //     dateCoupleTo.datepicker("setDaysOfWeekDisabled", ['0', '1', '2', '3', '4', '5', '6']);
      //   };
      // };
      break;
    case "shared":
      newDate.setDate(newDate.getDate());
      break;
    case "sleepin":
      rental_type_shift = sleepinMinRentalTime
      newDate.setDate(newDate.getDate() + rental_type_shift);
      newDateStart = newDate;
      if (newDateStored > newDate) {
        newDate = newDateStored;
      }
      if(hasBlockedDays(fromDate, newDate, sleepinBlockedDates)) {
        newDate = null;
        dateCoupleTo.datepicker("setDaysOfWeekDisabled", ['0', '1', '2', '3', '4', '5', '6']);
      };
      
      // newDate.setDate(newDate.getDate() + sleepinMinRentalTime);
      // if(hasBlockedDays(fromDate, newDate, sleepinBlockedDates)) {
      //   newDate = null;
      //   dateCoupleTo.datepicker("setDaysOfWeekDisabled", ['0', '1', '2', '3', '4', '5', '6']);
      // };
      break;
    default:
      newDate.setDate(newDate.getDate());
  };

  dateCoupleTo.datepicker("setDate", newDate);
  dateCoupleTo.datepicker("setStartDate", newDateStart);
  dateCoupleTo.datepicker("update", newDate);
};

// Instant booking
function instantBooking() {
  var bookingBtn = $('.message-action').find('.calculator-action-btn');
  var rentalType;
  if(countTypeVal === 1 || countTypeVal === 2 || countTypeVal === 3 || countTypeVal === 4) {
    rentalType = 'classic';
  } else if(countTypeVal === 5) {
    rentalType = 'shared';
  } else {
    rentalType = 'sleepin';
  }
  var dataBooking = bookingBtn.data('instant-booking-' + rentalType);
  var btnDataInstant = bookingBtn.data('instant-booking-enabled-text');
  var btnDataRequest = bookingBtn.data('instant-booking-disabled-text');

  if(dataBooking === true) {
    bookingBtn.text(btnDataInstant);
  } else {
    bookingBtn.text(btnDataRequest);
  }
};

// Render data from server at calc
function getMainValues(form) {
 
  var countTypeVal =  parseInt($('.price-select').find('option:selected').val()); // TO DO
  var passengersInput = $("input.passengers-input");
  var priceUnit = $('.price-select').find('option:selected').data("price-unit");
  var labelName = priceUnit;
  var resultQuantity;
  var calcTable = $("#calc-table");

  var form = $('#new-booking-form');
  var dateFrom = form.find("#dateFrom");
  var dateTo = form.find("#dateTo");
  var path = form.data('api-path');
  var data = form.serialize();

  if (dateFrom.val() !== "" && dateTo.val() !== "") {
    
    $.ajax({
      type: "GET",
      url: path,
      data: data,
      dataType: 'json',
      cache: false,
      async: false,
      success: function(data){
        if (data) {

          if (typeof(data.error) !== 'undefined') {
            $('.message-action .hide-on-zero-price').hide();
            $('#flash_messages').prepend('<div class="alert alert-alert"><div class="alert-text">'
              + data.error
              + '</div><button class="alert-close button btn-negative">Close</button></div>');
            slowFlashHide();
            return false;
          }
  
          var prices = data;
    
          if(countTypeVal === 5) { // TO DO
            labelName = 'passengers';
            resultQuantity = prices.passenger_quantity;
          } else {
            resultQuantity = prices.per_quantity;
          }
        
          calcTable.slideDown();
  
          form.find(".price-no-fee").text(prices.subtotal.replace(/[^ .0-9]/gim,'').trim());
          form.find("#quantityPrice").text(prices.unit_price.replace(/[^ .0-9]/gim,'').trim());
          form.find("#pricePerPassenger").text(prices.person_price.replace(/[^ .0-9]/gim,'').trim());
          form.find(".pass-count").text(resultQuantity);
          if(prices.client_fee !== undefined){
            form.find(".service-fee-number").text(prices.client_fee.replace(/[^ .0-9]/gim,'').trim());
          };
          if(prices.skipper_fee !== undefined){
            form.find(".skipper-fee-number").text(prices.skipper_fee.replace(/[^ .0-9]/gim,'').trim());
          };
          if(prices.cleaning_fee !== undefined){
            form.find(".cleaning-fee-number").text(prices.cleaning_fee.replace(/[^ .0-9]/gim,'').trim());
          };
          form.find(".price-total .total").text(prices.total.replace(/[^ .0-9]/gim,'').trim());
          form.find(".label-name").text(labelName);
        
          // hide booking button if total price is zero:
          var totalPricePositive = parseFloat(prices.total.replace(/[^ .0-9]/gim,'').trim()) > 0
          $('.message-action .hide-on-zero-price').toggle(totalPricePositive);

          // change passenger-input's max and min values
          var maxPass = prices.max;
          var minPass = prices.min;
          var passengersInputValue = parseInt(passengersInput.val());
        
          passengersInput.prop({
            max: maxPass,
            min: minPass
          });
        
          // if input passenger's value is bigger than max value then set passenger's input value to minPass
          if (passengersInputValue > maxPass) {
            passengersInput.val(minPass)
          }
        
          // if input passenger's value is less than min value then set passenger's input value to minPass
          if(passengersInputValue < minPass) {
            passengersInput.val(minPass);
          }
    
          passengersInput.trigger('refresh');
  
        }; 
      },
      error: function(error) {
        console.log(error.responseText);
      }
    });
  };
};

// Functional bridge fo rendering calc data
function render_calculator(form) {
  getMainValues(form);
}

// For calc ready
$(document).ready(function() {



  // Declarate variables
  var form = $('#new-booking-form');
  var startRentalType = $('#new-booking-form').data('rental-type');
  var dateFromInput = $('#dateFrom');
  var dateToInput = $('#dateTo');
  var priceSelect = $('#price_type');
  var calcTable = $("#calc-table");

  // Declarate minimum rental parameters
  var minRentalTime, sleepinMinRentalTime, canHalfDay;
  if(form.length !== 0) {
    minRentalTime = form.data("min-rental-time") / 86400;
    sleepinMinRentalTime = form.data("sleepin-min-rental-time") / 86400;
    canHalfDay = minRentalTime < 1;
  };

  // Calculcate blocked dates
  var blockedObj = {
    classic_blocked: [],
    shared_blocked: [],
    sleepin_blocked: [],
    booking_blocked: [],
  };
  if(form.length !== 0) {
    if(form.data("booking-blockings") !== 0) {
      form.data("booking-blockings").forEach(function(item){
        var dates = getStringDates(item.started_at, item.finished_at);
        blockedObj[(item.rental_type + "_blocked")] = blockedObj[item.rental_type + "_blocked"].concat(dates);
      });
    };
    if(form.data("bookings") !== 0) {     
      form.data("bookings").forEach(function(item){
        var dates = getStringDates(item.check_in, item.check_out);
        if(item.rental == "shared") {
          if(item.free_seats == 0) {
            blockedObj.booking_blocked = blockedObj.booking_blocked.concat(dates)
          } else {
            blockedObj.classic_blocked = blockedObj.classic_blocked.concat(dates);
            blockedObj.sleepin_blocked = blockedObj.sleepin_blocked.concat(dates);
          }
        } else {
          blockedObj.booking_blocked = blockedObj.booking_blocked.concat(dates)
        }
      });
    };
  }
  function blockingDates(type) {
    var $dates = blockedObj.booking_blocked.concat(blockedObj[type + "_blocked"]);
    dateFromInput.datepicker('setDatesDisabled', $dates);
    dateToInput.datepicker('setDatesDisabled', $dates);
  };

  // Rental type switcher
  function rentalSwitcher(type) {
    dateToInput.attr("disabled", false);
    dateFromInput.val('').datepicker('update');
    dateToInput.val('').datepicker('update');
    calcTable.slideUp();
    switch(type) {
      case 'classic':

        if(canHalfDay) {
          priceSelectUpdate(["half day", "full day"]);
          $(".ws-wrapper").hide();
        } else {
          priceSelectUpdate(["full day"]);
          $(".ws-wrapper").show();
        };

        $("#skipper_included").removeClass("disabled");
        $("#skipper_included_full").show();
        $("#skipper_included_yes").hide();
        $("#skipper_included_no").hide();

        blockingDates("classic");
        
        if($(".skipper-fee").length !== 0 && $("#skipper_included").val() == "true") {
          $(".skipper-fee-wrapper").show();
        };
        if($(".cleaning-fee").length !== 0) {
          $(".cleaning-fee").show();
        };

        $("#price_type").removeClass("disable-select-price");
        break;
      case 'shared':
        priceSelectUpdate(["shared"]);
        blockingDates("shared");
        dateToInput.attr("disabled", true);

        $("#skipper_included_full").hide();
        $("#skipper_included_no").hide();
        $("#skipper_included_yes").show();

        if($(".skipper-fee").length !== 0) {
          $(".skipper-fee-wrapper").hide();
        };
        if($(".cleaning-fee").length !== 0) {
          $(".cleaning-fee").hide();
        };
        $(".ws-wrapper").hide();

        $("#price_type:not(.disable-select-price)").addClass("disable-select-price");
        break;
      case 'sleepin':
        priceSelectUpdate(["sleepin"]);
        blockingDates("sleepin");

        $("#skipper_included_full").hide();
        $("#skipper_included_no").show();
        $("#skipper_included_yes").hide();

        if($(".skipper-fee").length !== 0) {
          $(".skipper-fee-wrapper").hide();
        };
        if($(".cleaning-fee").length !== 0) {
          $(".cleaning-fee").show();
        };
        $(".ws-wrapper").hide();

        $("#price_type:not(.disable-select-price)").addClass("disable-select-price");
        break;
      default:
        break;
    };
  };

  // Activate related tabs
  $('.tabs-container').tabs({
    activate: function(event, ui){
      var select = $('.price-select');
      var tab_num = $(this).tabs("option", "active");
      if (ui.newTab != ui.oldTab) {
        var $other_tabs = $(".tabs-container");
        $other_tabs.each(function(key, tab_item) {
          $(tab_item).tabs("option", "active", tab_num);
        });
      }
    },
  });

  // Tabs switchers
  $('.tabs-container a').on("click", function() {
    rentalSwitcher($(this).data("tabname"));
  });

  // Want sleep functions
  $('.want-sleep').on("click", function(e){
    e.preventDefault();
    $(this).hide();
    $(".dont-want-sleep").show();
    $(this).parent().data("night", "yes");

    priceSelectUpdate(["night"]);


    updateDate(blockedObj);
    render_calculator(form);
    //dateFromInput.val('').datepicker('update');
    //dateToInput.val('').datepicker('update');
  });
  $('.dont-want-sleep').on("click", function(e){
    e.preventDefault();
    $(this).hide();
    $(".want-sleep").show();
    $(this).parent().data("night", "no");

    if(canHalfDay) {
      priceSelectUpdate(["full day", "half day"]);
    } else {
      priceSelectUpdate(["full day"]);
    };

    updateDate(blockedObj);
    render_calculator(form);
    //dateFromInput.val('').datepicker('update');
    //dateToInput.val('').datepicker('update');
  });

  // Init datepicker
  initCalendar("#dateFrom", "#dateTo");

										   
						   
				   
													   
								
			
				  
													   
							   
			
				   
													   
								
			
			
			
	
															   
									   

  // Enabled/Disabled night mode AND selecting events
  priceSelect.on("change", function(){
    if ($(this).find("option:selected").data("price-unit") === "full day") {
      $(".ws-wrapper").show();
      render_calculator(form);
    } else if ($(this).find("option:selected").data("price-unit") === "half day") {
      $(".ws-wrapper").hide();
      render_calculator(form);
    };
  })

  // Change Date From
  dateFromInput.on('changeDate', function(event) {
    calcTable.slideUp();
    updateDate(blockedObj);
    // var priceUnit = $("#price_type option:selected").data("price-unit");
    // if(priceUnit === "half day" || priceUnit === "full day") {
    //   if($('#dateFrom').datepicker('getDate').getTime() === $('#dateTo').datepicker('getDate').getTime()) {
    //     if(canHalfDay) {
    //       priceSelectUpdate(["half day", "full day"]);
    //     } else {
    //       priceSelectUpdate(["full day"]);
    //     };
    //   };
    // };
    render_calculator(form);
  });

  // Change Date To
  dateToInput.on('changeDate', function(){
    var priceUnit = $("#price_type option:selected").data("price-unit");
    if(dateFromInput.val().length !== 0 && dateToInput.val().length !== 0) {
      if(priceUnit === "half day" || priceUnit === "full day") {
        if(dateFromInput.datepicker('getDate').getTime() === dateToInput.datepicker('getDate').getTime()) {
          if(canHalfDay) {
            priceSelectUpdate(["half day", "full day"]);
            $(".ws-wrapper").hide();
          } else {
            priceSelectUpdate(["full day"]);
            $(".ws-wrapper").show();
          };
        } else {
          priceSelectUpdate(["full day"]);
          $(".ws-wrapper").show();
        };
      };
    };
    
    if(dateFromInput.val().length === 0) {
      var fromDate = dateToInput.datepicker('getDate');
      dateFromInput.datepicker("setDate", fromDate);
    };

    render_calculator(form);
  });

  // Update Calculation
  form.find(".passengers-item input").change(function(){
    render_calculator(form);
  });

  // Captain switcher events
  $("#skipper_included").on("change", function(){
    if($(this).val() === "true") {
      $(".skipper-fee-wrapper").show();
    } else {
      $(".skipper-fee-wrapper").hide();
    };
    render_calculator(form);
  });

  // Set start days
  var params = window
  .location
  .search
  .replace('?','')
  .split('&')
  .reduce(
    function(p,e){
        var a = e.split('=');
        p[ decodeURIComponent(a[0])] = decodeURIComponent(a[1]);
        return p;
    },
    {}
  );

  //Set RentalType
  if(params.startRentalType) {
    startRentalType = params.startRentalType;
    rentalSwitcher(startRentalType);
    console.log ('tipo: ' + params.startRentalType + 'variable= ' + startRentalType);
  };
  // Setup start rental type and start tabs
  switch(startRentalType) {
    case 'classic':
      $(".tabs-container").tabs("option", "active", 0);
      rentalSwitcher("classic");
      break;
    case 'shared':
      $(".tabs-container").tabs("option", "active", 1);
      rentalSwitcher("shared");
      break;
    case 'sleepin':
      $(".tabs-container").tabs("option", "active", 2);
      rentalSwitcher("sleepin");
      break;
    default:
      break;
  };
  $('.tabs-container').find('.ui-tabs-nav li.hidden').remove();
  $('.tabs-container').tabs('refresh');

  if(params.check_in_date) {
    dateFromInput.datepicker("setDate", params.check_in_date);
  };
  if(params.check_out_date && startRentalType !== "shared") {
    dateToInput.datepicker("setDate", params.check_out_date);
  };




  $('.message_form_send').click(function(e) {
    e.preventDefault();
    var $textarea = $("#message");
    if ($textarea.val().trim().length < 2) {
      if(($textarea.parent().find('.field-error').length == 0)) {
        $textarea.parent().append('<span class="field-error">Please write a message</span>');
      };
      $textarea.addClass('input-error');
      return false;
    } else {
      $textarea.siblings('.field-error').detach();
      $textarea.removeClass('input-error');
      $('form').submit();
    }
  })

});

$(document).load(function() {
  $.ajaxSetup({
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    }
  });
});

$(document).ready(function() {
  $('.listing-slider').slick({
    autoplay: true,
    arrows: true,
    autoplaySpeed: 5000
  });

  // Listing navigation.
  $('#switch_listing').on('select2:select', function () {
    $(location).attr('href', $(this).find('option:selected').data('path'));
  });

  // NOTE: This handler works only on listing/settings page thanks to
  // `$('.booking-settings-container')` selector.
  // And `$('input:radio').change()` event handler avoid to sending AJAX
  // requests after clicking on already selected radio button.
  $('.booking-settings-container input:radio').change(function () {
    var $radioButton = $(this);

    // Checks to avoid show/hide block by clicking on another radio buttons.
    if ($radioButton.is('#instant_booking_enabled')) {
      displayFlashMessage($('#instant_booking_block').data('turned-on-message'));

      $('#instant_booking_block').hide()
    }
    if ($radioButton.is('#instant_booking_disabled')) {
      displayFlashMessage($('#instant_booking_block').data('turned-off-message'));

      $('#instant_booking_block').show()
    }

    $.ajax({
      method: 'PATCH',
      dataType: 'json',
      url:  $radioButton.data('url'),
      data: $radioButton.data('payload'),
      success: function () { },
      error:   function (error) { console.log(error) }
    });
  });

  // Clicking on `Turn on instant booking` button also checks radio button.
  $('#enable_instant_booking_button').on('click', function () {
    $('input#instant_booking_enabled').click();
    $(this).closest('#instant_booking_block').hide();
  });

  $('.online-switch-label').on('click', function(){
    var $label = $(this),
        $input = $label.siblings('input'),
        boatId = $label.data('id'),
        $disabled_text = $label.data('disabled-text'),
        $enabled_text  = $label.data('enabled-text'),
        flag;
    if($input.prop('checked')) {
      flag = 0;
    } else {
      flag = 1;
    };
    var boatData = {
      classic: flag
    };
    $.ajax({
      type: 'PATCH',
      dataType: 'json',
      data: boatData,
      url: '/api/boats/' + boatId + '.json',
      success: function(data) {
        if($input.prop('checked')) {
          $label.text($enabled_text);
        } else {
          $label.text($disabled_text);
        };
      },
      error: function (error) {
        setTimeout(function () {
          $input.prop("checked", false)
        }, 700);
        $('#flash_messages').prepend('<div class="alert alert-alert"><div class="alert-text">'
          + error.responseJSON.message
          + '</div><button class="alert-close button btn-negative">Close</button></div>');
        slowFlashHide();
      }
    });
  });

  $('.sleepin-switch-label').on('click', function(e){
    var $label = $(this),
        $input = $label.siblings('input'),
        boatId = $label.data('id'),
        $disabled_text = $label.data('disabled-text'),
        $enabled_text  = $label.data('enabled-text'),
        $redirect_url  = $label.data('edit'),
        $child_checkbox = $label.parents('.y-listing-box').next().find('*[data-mode="sleepin"] .online_switcher'),
        $child_label    = $label.parents('.y-listing-box').next().find('.online-switch-label-additional'),
        boatData;
    if($input.prop('checked')) {
      boatData = {
        sleepin: 0
      };
    } else {
      boatData = {
        sleepin: 1
      };
    };
    $.ajax({
      type: 'PATCH',
      dataType: 'json',
      data: boatData,
      url: '/api/boats/' + boatId + '.json',
      success: function(data) {
        if($input.prop('checked')) {
          $label.text($enabled_text);
          $child_label.text($child_label.data('enabled-text'));
          $child_checkbox.prop('checked', true);
          location.assign($redirect_url);
        } else {
          $label.text($disabled_text);
          $child_label.text($child_label.data('disabled-text'));
          $child_checkbox.prop('checked', false);
        };
      },
      error: function (error) {
        setTimeout(function () {
          $input.prop("checked", false)
        }, 700);
        $('#flash_messages').prepend('<div class="alert alert-alert"><div class="alert-text">'
          + error.responseJSON.message
          + '</div><button class="alert-close button btn-negative">Close</button></div>');
        slowFlashHide();
      }
    });
  });

  $('.shared-switch-label').on('click', function(e){
    var $label = $(this),
        $input = $label.siblings('input'),
        boatId = $label.data('id'),
        $disabled_text = $label.data('disabled-text'),
        $enabled_text  = $label.data('enabled-text'),
        $redirect_url  = $label.data('edit'),
        $child_checkbox = $label.parents('.y-listing-box').next().find('*[data-mode="shared"] .online_switcher'),
        $child_label    = $label.parents('.y-listing-box').next().find('.online-switch-label-additional'),
        boatData;
    if($input.prop('checked')) {
      boatData = {
        shared: 0
      };
    } else {
      boatData = {
        shared: 1
      };
    };
    $.ajax({
      type: 'PATCH',
      dataType: 'json',
      data: boatData,
      url: '/api/boats/' + boatId + '.json',
      success: function(data) {
        if($input.prop('checked')) {
          $label.text($enabled_text);
          $child_label.text($child_label.data('enabled-text'));
          $child_checkbox.prop('checked', true);
          location.assign($redirect_url);
        } else {
          $label.text($disabled_text);
          $child_label.text($child_label.data('disabled-text'));
          $child_checkbox.prop('checked', false);
        };
      },
      error: function (error) {
        setTimeout(function () {
          $input.prop("checked", false)
        }, 700);
        $('#flash_messages').prepend('<div class="alert alert-alert"><div class="alert-text">'
          + error.responseJSON.message
          + '</div><button class="alert-close button btn-negative">Close</button></div>');
        slowFlashHide();
      }
    });
  });

  $('*[data-mode="sleepin"] .online-switch-label-additional').on('click', function(){
    var $label = $(this),
        $input = $label.siblings('input'),
        boatId = $label.data('id'),
        $disabled_text = $label.data('disabled-text'),
        $enabled_text  = $label.data('enabled-text'),
        $parent_checkbox = $label.parents('.y-listing-additions-container').prev().find('.sleepin-switch'),
        $parent_label    = $label.parents('.y-listing-additions-container').prev().find('.sleepin-switch-label'),
        flag;
    if($input.prop('checked')) {
      flag = 0;
    } else {
      flag = 1;
    };
    var boatData = {
      sleepin: flag
    }
    $.ajax({
      type: 'PATCH',
      dataType: 'json',
      data: boatData,
      url: '/api/boats/' + boatId + '.json',
      success: function(data) {
        if($input.prop('checked')) {
          $label.text($enabled_text);
          $parent_label.text($parent_label.data('enabled-text'));
          $parent_checkbox.prop('checked', true);
        } else {
          $label.text($disabled_text);
          $parent_label.text($parent_label.data('disabled-text'));
          $parent_checkbox.prop('checked', false);
        };
      },
      error: function (error) {
        setTimeout(function () {
          $input.prop("checked", false)
        }, 700);
        $('#flash_messages').prepend('<div class="alert alert-alert"><div class="alert-text">'
          + error.responseJSON.message
          + '</div><button class="alert-close button btn-negative">Close</button></div>');
        slowFlashHide();
      }
    });
  });

  $('*[data-mode="shared"] .online-switch-label-additional').on('click', function(){
    var $label = $(this),
        $input = $label.siblings('input'),
        boatId = $label.data('id'),
        $disabled_text = $label.data('disabled-text'),
        $enabled_text  = $label.data('enabled-text'),
        $parent_checkbox = $label.parents('.y-listing-additions-container').prev().find('.shared-switch'),
        $parent_label    = $label.parents('.y-listing-additions-container').prev().find('.shared-switch-label');
    var flag;
    if($input.prop('checked')) {
      flag = 0;
    } else {
      flag = 1;
    };
    var boatData = {
      shared: flag
    }
    $.ajax({
      type: 'PATCH',
      dataType: 'json',
      data: boatData,
      url: '/api/boats/' + boatId + '.json',
      success: function(data) {
        if($input.prop('checked')) {
          $label.text($enabled_text);
          $parent_label.text($parent_label.data('enabled-text'));
          $parent_checkbox.prop('checked', true);
        } else {
          $label.text($disabled_text);
          $parent_label.text($parent_label.data('disabled-text'));
          $parent_checkbox.prop('checked', false);
        };
      },
      error: function (error) {
        setTimeout(function () {
          $input.prop("checked", false)
        }, 700);
        $('#flash_messages').prepend('<div class="alert alert-alert"><div class="alert-text">'
          + error.responseJSON.message
          + '</div><button class="alert-close button btn-negative">Close</button></div>');
        slowFlashHide();
      }
    });
  });

  // Your listing details Gallery
  $('.yld-gallery').magnificPopup({
    delegate: 'a',
    type: 'image',
    tLoading: 'Loading image #%curr%...',
    mainClass: 'mfp-img-mobile',
    gallery: {
      enabled: true,
      navigateByImgClick: true,
      preload: [0,1]
    },
    image: {
      tError: '<a href="%url%">The image #%curr%</a> could not be loaded.',
      titleSrc: function(item) {
        return item.el.attr('title');
      }
    }
  });

  // `I agree to use instant booking` checkbox that switch enabling of `Save`
  // button for `boat.instant_booking_sleepin` and `boat.instant_booking_shared`
  // on listing sleepin/shared pages.
  $('.agree-switcher').on('change', function () {
    $('.button.next').toggleClass('btn-disabled', !$(this).prop('checked'))
  });
  // Check instant booking by default
  if (!$('#boat_instant_booking_classic').attr('checked')) {
    $(".agree-switcher").trigger("click");
  }

  // Validation Sleeping/Sharing Form
  function validateActivateForm(form) {

    var emptyTextMessage = 'Please enter a value',
        emptyTextareaMessage = 'Please enter a text for textarea',
        emptySelectMessage = 'Please select',
        emptyPrice = 'Please enter a price',
        activateForm = form;

    if(!activateForm.find('input[type="text"]').length == 0) {
      var inputText = activateForm.find('input[type="text"]');
      inputText.each(function(){
        if($(this).val() == '') {
          if(($(this).parent().find('.field-error').length == 0)) {
            $(this).parent().append('<span class="field-error">' + (($(this).hasClass('person-price'))?emptyPrice:emptyTextMessage) + '</span>');
          };
          $(this).addClass('input-error');
        } else {
          $(this).siblings('.field-error').detach();
          $(this).removeClass('input-error');
        }
      });
    };

    if(!activateForm.find('textarea').length == 0) {
      var textarea = activateForm.find('textarea');
      textarea.each(function(){
        if($(this).val() == '') {
          if(($(this).parent().find('.field-error').length == 0)) {
            $(this).parent().append('<span class="field-error">'+ emptyTextareaMessage + '</span>');
          };
          $(this).addClass('input-error');
        } else {
          $(this).siblings('.field-error').detach();
          $(this).removeClass('input-error');
        }
      });
    };

    if(!activateForm.find('select').length == 0) {
      var select = activateForm.find('select');
      select.each(function(){
        if($(this).val() == '') {
          if(($(this).parent().find('.field-error').length == 0)) {
            $(this).parent().append('<span class="field-error">'+ emptySelectMessage + '</span>');
          };
          $(this).addClass('input-error');
        } else {
          $(this).siblings('.field-error').detach();
          $(this).removeClass('input-error');
        }
      });
    };
  };

  $('#sleepin_form button[type="submit"]').on('click', function(e){
    e.preventDefault();

    var sleepinForm = $('#sleepin_form');
    validateActivateForm(sleepinForm);

    if(sleepinForm.find('.field-error').length == 0) {
      sleepinForm.submit();
    };

  });

  $('#sharing_form button[type="submit"]').on('click', function(e){
    e.preventDefault();

    var sharingForm = $('#sharing_form');
    validateActivateForm(sharingForm);

    if(sharingForm.find('.field-error').length == 0) {
      sharingForm.submit();
    };

  });

  // Adding to Wishlist
  $('.similar-list').on('click', '.wishlist-add', function(){ 
    var userId = $('#new-booking-form').data('current-user-id');
    var listingId = $(this).data('id');
    var messageText = $('#new-booking-form').data('title-add-wishlist');
    var ajaxType = 'POST';
    var ajaxData = { id: listingId };
    var ajaxUrlFragment = '';

    if($(this).hasClass('active')) {
      ajaxType = 'DELETE';
      ajaxData = {};
      ajaxUrlFragment = '/' + listingId;
      messageText = $('#new-booking-form').data('title-delete-wishlist');
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
  
  $('.btn-delete-listing-inprogress').on('click', function(e){
    e.preventDefault();
    var boatId = $(this).data('boat'); // Get boat ID from data-attributes
        deleteQuestionText = $(this).data("question");
        deletedListingText = $(this).data("deleted");
        url = $(this).attr('href');
        link = $(this);
        isDelete = confirm(deleteQuestionText);
    if (isDelete) {
      // TO DO Need correct ajax for deleting. Success callback already done
      $.ajax({
        url: url,
        data: {_method: 'delete'},
        method: 'post',
        success: function(){
          $('#flash_messages').prepend('<div class="alert alert-alert"><div class="alert-text">'
          + deletedListingText
          + '</div><button class="alert-close button btn-negative">Close</button></div>');
          slowFlashHide();
          link.parents('.y-listing-progress-box').hide();
        },
        error: function (error) {
          console.log(error);
        }
      });
    };
  });

});
