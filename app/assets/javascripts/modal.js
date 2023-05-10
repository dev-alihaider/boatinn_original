$(function () {
  $(document)
    .on('ajax:success', '#login-in-user', function (e, data, status, xhr) {
      if (data.location != undefined) {
        if (data.location.indexOf('/prewizards') + 1) {
          var goUrl = $('#language').find('option:selected').attr('data-url').replace(/pre/g, '');
          goUrl = goUrl + '/new';
          location.assign(goUrl);
        } else {
          location.reload(data.location);
        }
      }
    })
    .on("ajax:error", '#login-in-user', function (e, data, status, xhr) {
      if (data.responseJSON) {
        $('#modal-container .error').html(data.responseJSON.errors);
      }
    })
    .on("ready", function () {

    });

  var back = '<div class="modal-background"></div>',
      container = $('#modal-container'),
      body = $('body');

  $(document).on('ajax:success', '*[data-modal]', function (e, data, status, xhr) {
    if (status == 'success') {
      body.append(back);
      body.addClass('modal-open');
      container.html(data);
    } else {
      alert('failure!');
    }
  });

  $(document).on('click', '.auth-panel a', function () {
    $('.home-slider .slick-track').css({'min-width': '100vw'});
  });
  container.on('click', '.btn-close', function () {
    $('.home-slider .slick-track').css({'min-width': ''});
    body.find('.modal-background').detach();
    body.removeClass('modal-open');
    container.empty();
  });

  $(document)
    .on('ajax:success', '#sign-up_user', function (e, data, status, xhr) {
      if (status == 'success') {
        if (data.success) {
          //close popup
          body.find('.modal-background').detach();
          body.removeClass('modal-open');
          container.empty();
          //print success message
          if(data.message) {
              displayFlashMessage(data.message);
          }

          if(data.redirect_to){
              window.location = data.redirect_to
              return false;
          }
        } else {
          //add errors into popup
          // $('#modal-container .error').html(data.message);
          show_form_errors('user', data.errors);
        }
      } else {
        alert('failure!');
      }
    })
    .on("ajax:error", '#sign-up_user', function (e, data, status, xhr) {
      alert(data.responseText);
    });

});

$(document).on('ajax:before', '#sign-up_user', function () {
  remove_form_errors($('#sign-up_user'));
});

$(document).on('click', '.popup .btn-switch', function (e) {
  e.preventDefault();
  $('.social-enter').hide();
  $('.general-enter').hide();
  $('.form-divide').hide();
  $('.simple-enter').show();

  $(".select2.month").select2({
    minimumResultsForSearch: -1,
    placeholder: "Month"
  });
  $(".select2.day").select2({
    minimumResultsForSearch: -1,
    placeholder: "Day"
  });
  $(".select2.year").select2({
    minimumResultsForSearch: -1,
    placeholder: "Year"
  });
});

$(document).on('click', '.popup .link-to', function (e) {
  e.preventDefault();
  $('.social-enter').show();
  $('.general-enter').show();
  $('.form-divide').show();
  $('.simple-enter').hide();
});

$(document).on('click', '#forgot-password-link', function (e) {
  e.preventDefault();
  $('.forgot-hide').hide();
  $('.forgot-show').show();
});

$(document).on('click', '#forgot-password-send', function (e) {
  e.preventDefault();
  var email = $('#user_email').val();
  $.ajax({
    type: 'POST',
    dataType: 'json',
    data: {user: {email: email}},
    url: '/users/password',
    cache: false,
    success: function (data) {
      $('#user_email').hide();
      $('.forgot-show').hide();
      $('#login-in-user').append('<div class="custom-forgot-box">' + data.message + '</div>');
    },
    error: function (error) {
      $('#user_email').hide();
      $('.forgot-show').hide();
      $('#login-in-user').append('<div class="custom-forgot-box">' + error.responseJSON.errors + '</div>');
    }
  });
});

function show_form_errors(name, errors) {
  Object.keys(errors).map(function (error_key) {
    var message = errors[error_key].join(', ');
    var input = $("#" + name + "_" + error_key);
    var error_label = input.parent().find(".field-error");
    if (!error_label.length) {
      error_label = $("<span class='field-error'></span>");
      error_label.insertAfter(input);
    }
    input.addClass('input-error');
    error_label.html(message);
  });
  if ($("#user_birthday").hasClass("input-error")) {
    $("#user_birthday .select2").each(function () {
      if (!$(this).val()) {
        $(this).addClass("input-error");
      }
    })
  };
};

function remove_form_errors(form) {
  form.find(".field-error").hide();
  form.find(".field-error").removeClass('error');
};
