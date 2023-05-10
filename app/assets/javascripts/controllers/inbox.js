//= require ../application
//= require jquery.rateyo.min

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
  while (currentDate.getTime() <= stopDate.getTime()) {
    var stringD = currentDate.getFullYear() + '-' +
                  String(currentDate.getMonth() + 1).replace(/^(.)$/, "0$1") + '-' +
                  String(currentDate.getDate()).replace(/^(.)$/, "0$1");
    dateArray.push(stringD);
    currentDate = currentDate.addDays(1);
  }
  return dateArray;
};

// Adaptive mobile table
function messagesAdapting() {
  if(($(".mobile-messages-table").length !== 0) && ($(window).width() < 768)) {
    var mobileMessagesTable = $(".mobile-messages-table");
    $(".messages-row").each(function(){
      var $withClasses = $(this).hasClass("unread") ? "<div class='mobile-messages-row unread'>" : "<div class='mobile-messages-row read'>";
      var mobileMessagesRow = $withClasses +
                                "<div class='left-col'>" +
                                  $(this).find(".msg-info .avatar").get(0).outerHTML +
                                "</div>" +
                                "<div class='right-col'>" +
                                  "<div class='msg-conversation'>" +
                                    $(this).find(".msg-conversation .title").get(0).outerHTML +
                                    $(this).find(".msg-conversation .date").get(0).outerHTML +
                                    $(this).find(".msg-conversation .content").get(0).outerHTML +
                                  "</div>" +
                                  "<div class='msg-type-status'>" +
                                    $(this).find(".msg-type").get(0).outerHTML +
                                    $(this).find(".msg-status").get(0).outerHTML +
                                  "</div>" +
                                "</div>" +
                              "</div>";
      mobileMessagesTable.append(mobileMessagesRow);
    });
  }
};

$(document).ready(function() {
  // Messages sender filter.
  $('#filter_messages_from').on('select2:select', function () {
    $(location).attr('href', $(this).find('option:selected').data('path'));
  });

  // ajax navigation
  remote_inbox_navigate($("#inbox-container"));

  // sidebar datepicker
  if($('.book-inbox-calendar').length) {
    var calendar = $('.book-inbox-calendar');

    var datesDisabled = [];
    var bookingsDate = calendar.data("bookings");
    var blockedDate = calendar.data("booking-blockings");

    bookingsDate.map(function(item){
      datesDisabled = datesDisabled.concat(getStringDates(item.check_in, item.check_out))
    });

    blockedDate.map(function(item){
      datesDisabled = datesDisabled.concat(getStringDates(item.started_at, item.finished_at))
    });

    calendar.datepicker({
      format: 'yyyy-mm-dd',
      datesDisabled: datesDisabled
    });
  }

  // get messages by ajax
  if ($(".chat-window").length) {
      run_ajax_chat();
  }

  // Reviews
  $(".review-rating").each(function(){
    $(this).prepend("<div class='review-stars'></div>");
    var $stars = $(this).find('.review-stars');
    var $field = $(this).find('.review-field');
    var $startValue = $field.val() ? $field.val() : 0;
    $stars.rateYo({
      starWidth: "25px",
      rating: $startValue,
      fullStar: true,
      spacing: "5px",
      ratedFill: "#ff9600",
      normalFill: "#5C606B",
      onSet: function (rating, rateYoInstance) {
        $field.val(rating);
      }
    });
  });

  $(".rec-smile").on("click", function(e){
    e.preventDefault();
    if(!$(this).hasClass("active")) {
      $(this).addClass("active");
      $(".rec-frown").removeClass("active");
      $("#review_would_recommend").val(true);
    }
  });

  $(".rec-frown").on("click", function(e){
    e.preventDefault();
    if(!$(this).hasClass("active")) {
      $(this).addClass("active");
      $(".rec-smile").removeClass("active");
      $("#review_would_recommend").val(false);
    }
  });

  var isRecommend = $("#review_would_recommend").val();
  if(isRecommend) {
    $(".rec-smile").addClass("active");
  } else {
    $(".rec-frown").addClass("active");
  };

  messagesAdapting();
  $(window).resize(function(){
    messagesAdapting();
  });

  $('.inbox-message-sent').click(function(e) {
    e.preventDefault();
    var $textarea = $("#travel_message_content");
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

function remote_inbox_navigate(container) {
  container.find(".remote-links a").click(function(e){
    e.preventDefault();
    $.get($(this).attr('href'), function(body){
      container.html(body);
      /* set event again for new dom */
      remote_inbox_navigate(container);
      container.append("<div class='mobile-messages-table'></div>");
      messagesAdapting();
    });
  }); /* end click */
}

var checkNewMessagesRefreshIntervalId = 0;

function run_ajax_chat() {
  checkNewMessagesRefreshIntervalId = setInterval(function () {
    check_and_write_new_messages();
  }, 1000);
}

function check_and_write_new_messages() {
  var chat_window = $('.chat-window');
  var last_id = chat_window.find('.message-box[data-message-id]').eq(0).data('message-id');

  $.get(window.location.pathname, {last_id: last_id}, function (response) {
    if (typeof response.email !== 'undefined' && response.email === '' &&
        typeof response.password !== 'undefined' && response.password === null) {
      clearInterval(checkNewMessagesRefreshIntervalId);
      document.location = '/users/sign_in';
    } else {
      if (response.messages.length) {
        chat_window.prepend(response.messages);
      }
      $('.booking-status').html(response.status);
    }
  }, 'json')
}
