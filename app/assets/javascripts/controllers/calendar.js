//= require ../application
//= require ../availability-calendar 

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

function getDates(startDate, stopDate) {
  var dateArray = new Array();
  var currentDate = startDate;
  while (currentDate <= stopDate) {
      dateArray.push(new Date(currentDate));
      currentDate = currentDate.addDays(1);
  }
  return dateArray;
};

function getCalendar(id) {
  if(id) {
    var $url = "/api/boats/" + id + "/booking_blockings.json";
    $.ajax({
      type: 'GET',
      url: $url,
      success: function(data){
  
        var blockedObj = {
          classic_blocked: [],
          shared_blocked: [],
          sleepin_blocked: [],
        };
  
        data.booking_blockings.forEach(function(item){
          var dates = getStringDates(item.started_at, item.finished_at);
          blockedObj[(item.rental_type + "_blocked")] = blockedObj[item.rental_type + "_blocked"].concat(dates);
        });
  
        var $bookings = [];
        if(data.bookings.length !== 0) {
          data.bookings.forEach(function(item){
  
            var check_in_date = new Date(item.trip.check_in);
            var check_out_date = new Date(item.trip.check_out);
            var $check_in = check_in_date.getFullYear() + '-' +
                            String(check_in_date.getMonth() + 1).replace(/^(.)$/, "0$1") + '-' + 
                            String(check_in_date.getDate()).replace(/^(.)$/, "0$1");
            var $check_out = check_out_date.getFullYear() + '-' +
                            String(check_out_date.getMonth() + 1).replace(/^(.)$/, "0$1") + '-' + 
                            String(check_out_date.getDate()).replace(/^(.)$/, "0$1");
  
            var $booking = {
              booking: {
                id: item.booking.id,
                rental_type: item.trip.rental,
                start_at: $check_in, 
                end_at: $check_out, 
              },
              conversation_url: item.conversation_url,
              client: {
                  name: item.client.name,
                  photo: item.client.photo,
                  profile_url: item.client.profile_url
              }
            };
            $bookings.push($booking);
          });
        };
        availCalendar.init({
          container: '.dsh-calendar',
          view: 'm',
          customObj: $bookings,
          dateClasses: blockedObj,
          firstY: $('.dsh-calendar').data("first-year"),
          lastY: $('.dsh-calendar').data("last-year"),
          additionalFunc: function() {
            $(".ac-month-switcher").select2({
              minimumResultsForSearch: -1
            });
            $(".ac-year-switcher").select2({
              minimumResultsForSearch: -1
            });
          }
        });
  
      },
      error: function (error) {
        console.log(error);
      }
    });
  };
};

$(document).ready(function() {
  
  var swicthBoat = $("#switch_listing");

  getCalendar(swicthBoat.val());

  swicthBoat.on("change", function(){
    getCalendar(swicthBoat.val());
  });
  
  // Type Switcher
  $(".type-switch-link").on("click", function(e){
    e.preventDefault();
    var $this = $(this);
    if(!$this.hasClass("active")) {
      $this.addClass("active");
      $this.siblings().removeClass("active");
      $(".dsh-calendar-wrapper").attr("class", ("dsh-calendar-wrapper type-" + $(this).data("type") + "-view"));
    };
  });

  // Availability Switcher
  var availFrom = $('.avail-from'),
      availTo = $('.avail-to'),
      availGeneral = $('.datepicker-avail');
      availBtn = $(".btn-change-avail");
  availGeneral.datepicker({
    format: 'yyyy-mm-dd',
    autoclose: true,
    startDate: new Date()
  });
  availFrom.on('changeDate', function () {
    availTo.val('').datepicker('setStartDate',$(this).datepicker('getDate'));
  });
  availGeneral.on('change', function () {
    if(!(availFrom.val() == "") && !(availTo.val() == "")) {
      availBtn.removeClass("btn-disabled");
    } else {
      availBtn.addClass("btn-disabled");
    };
  });
  availBtn.on("click", function(e){
    e.preventDefault();
    $("#avail_error").text('');
    var avail_type = parseInt($('.input-boat-status:checked').val());
    var rental_type = $('.type-switch-link.active').data('type');
    if (avail_type === 1) {

      var $url = "/api/boats/" + $("#switch_listing").val() + "/booking_blockings.json";

      $.ajax({
        type: 'DELETE',
        url: $url,
        data: {
          rental_type: rental_type,
          date_from: availFrom.val(),
          date_to: availTo.val(),
        },
        success: function(data){
          $.ajax({
            type: 'GET',
            url: $url,
            success: function(data){
              var blockedObj = {
                classic_blocked: [],
                shared_blocked: [],
                sleepin_blocked: [],
              };
              data.booking_blockings.forEach(function(item){
                var dates = getStringDates(item.started_at, item.finished_at);
                blockedObj[(item.rental_type + "_blocked")] = blockedObj[item.rental_type + "_blocked"].concat(dates);
              });
              availCalendar.update({
                dateClasses: blockedObj,
                dateClassesUpdateForce: true
              });
            },
            error: function (error) {
              $("#avail_error").text(error.responseJSON.message);
            }
          });
        },
        error: function (error) {
          $("#avail_error").text(error.responseJSON.message);
        }
      });

    } else {
      if (avail_type === 3) {
        rental_type = 'all';
      };

      $.ajax({
        type: 'POST',
        dataType: 'json',
        url: '/api/boats/' + $("#switch_listing").val() + '/booking_blockings.json',
        data: {
          rental_type: rental_type,
          date_from: availFrom.val(),
          date_to: availTo.val(),
        },
        success: function(data){
  
          var blockedObj = {
            classic_blocked: [],
            shared_blocked: [],
            sleepin_blocked: [],
          };
  
          if(data.booking_blockings.boat_id) {
            blockedObj[(data.booking_blockings.rental_type + "_blocked")] = getStringDates(data.booking_blockings.started_at, data.booking_blockings.finished_at);
          } else {  
            data.booking_blockings.forEach(function(item){
              var dates = getStringDates(item.started_at, item.finished_at);
              blockedObj[(item.rental_type + "_blocked")] = blockedObj[item.rental_type + "_blocked"].concat(dates);
            });
          };
          
          availCalendar.update({
            dateClasses: blockedObj
          });
  
        },
        error: function (error) {
          $("#avail_error").text(error.responseJSON.message);
        }
      });

    };

  });
});