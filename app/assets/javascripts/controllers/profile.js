//= require application
//= require jquery.remotipart
//= require report_about_review

$(document).ready(function () {
  var $phoneNumberInput = $('#phone-number-input'),
      $numberVerifiedBadge = $('#number-verified-badge'),
      $sendCodeButton = $('#send-code-button'),
      $verificationCodeInput = $('#verification-code-input'),
      $verifyCodeButton = $('#verify-code-button'),
      $cancelVerificationButton = $('#cancel-verification-button'),
      $statusMessage = $('#status-message'),
      $statusMessageText = $('#status-message-text');

  // == Verify phone number via SMS code ==
  // TODO: Replace this custom i18n with Rails -> JS via gem.
  const i18n = {
    messages: {
      numberValidReadyForSendingCode: 'Number valid, ready for sending code.'
    },
    errors: {
      error: 'Error: ',
      numberIsEmpty: 'then number is empty.',
      numberIsIncorrect: 'the number is incorrect.',
      numberIsTooShort: 'the number is too short.',
      numberIsTooLong: 'the number is too long.',
      numberIsNotANumber: 'the number is not a number.',
      numberIsSame: 'the number is same and already verified.',
      verificationCodeTooShort: 'verification code too short.',
      verificationCodeTooLong: 'verification code too long.' // TODO: this probably not needed
    },
    params: {
      verificationCodeLength: 5,
      verificationCodeCooldown: 60
    }
  };

  function enableButton(jQueryButton, enabled) {
    jQueryButton.prop('disabled', !enabled);
    enabled ? jQueryButton.removeClass('btn-disabled') : jQueryButton.addClass('btn-disabled');
  }

  function displayElement(jQueryElement, displayed) {
    displayed ? jQueryElement.removeClass('hidden') : jQueryElement.addClass('hidden');
  }

  function displayStatusMessage(message) {
    $statusMessageText.text(message);
  }

  function disableSendCodeButtonForCooldown() {
    enableButton($sendCodeButton, false);
    window.setTimeout(function () {
      // Can be replaced by #validatePhoneNumber() here.
      enableButton($sendCodeButton, true);
    }, i18n.params.verificationCodeCooldown * 1000);
  }

  function validatePhoneNumber() {
    // Filter non-digits from input value.
    if ($phoneNumberInput.length !== 0) {
      if (/\D/g.test($phoneNumberInput.val())) {
        $phoneNumberInput.val($phoneNumberInput.val().replace(/\D/g, ''));
      }

      var isValidNumber = $phoneNumberInput.intlTelInput('isValidNumber'),
          validationError = $phoneNumberInput.intlTelInput('getValidationError'),
          message = i18n.errors.error,
          isShowNumberVerifiedBadge = false;

      if (isValidNumber) {
        // Disable verification of already verified current number.
        if ($phoneNumberInput[0].defaultValue == $phoneNumberInput.intlTelInput('getNumber')
            && $phoneNumberInput.data('is-verified-number')) {
          isValidNumber = false;
          message += i18n.errors.numberIsSame;
          isShowNumberVerifiedBadge = true;
        } else {
          message = i18n.messages.numberValidReadyForSendingCode;
        }
      } else {
        switch (validationError) {
          case intlTelInputUtils.validationError.IS_POSSIBLE:
            message += i18n.errors.numberIsIncorrect;
            break;
          case intlTelInputUtils.validationError.TOO_SHORT:
            message += i18n.errors.numberIsTooShort;
            break;
          case intlTelInputUtils.validationError.TOO_LONG:
            message += i18n.errors.numberIsTooLong;
            break;
          case intlTelInputUtils.validationError.NOT_A_NUMBER:
            if ($phoneNumberInput.intlTelInput('getNumber').length === 0) {
              message += i18n.errors.numberIsEmpty
            } else {
              message += i18n.errors.numberIsNotANumber;
            }
            break;
          default:
            message += i18n.errors.numberIsIncorrect;
            break;
        }
      }
      enableButton($sendCodeButton, isValidNumber);
      displayStatusMessage(message);
      displayElement($statusMessage, true);
      displayElement($numberVerifiedBadge, isShowNumberVerifiedBadge);
    }
  };

  // Init Telephone Input JavaScript plugin.
  // length != 0 for run validatePhoneNumber() only on page where input present
  if ($phoneNumberInput.length > 0) {
    $phoneNumberInput.intlTelInput({
      preferredCountries: ["es", "gb", "fr", "de", "it", "nl"]
    }).done(function () {
      if (!$phoneNumberInput.data('is-verified-number')) {
        validatePhoneNumber();
      }

      // Set maxlength via JS and not via html because when phone plugin
      // started it cut off full number:
      // `+380961234567` -> `3809612345` and this phone not passes validation
      // function #validatePhoneNumber() and became invalid.
      $phoneNumberInput.attr('maxlength', 10);

      $phoneNumberInput.on('keyup', function () {
        validatePhoneNumber();
      });
    });
  }

  // Button for sending SMS with verification code.
  $sendCodeButton.on('click', function () {
    displayStatusMessage($statusMessage.data('info'));
    displayElement($('#input-code-row'), true);
    disableSendCodeButtonForCooldown();

    $.ajax({
      type: 'POST',
      dataType: 'json',
      data: {phone_number: $phoneNumberInput.intlTelInput('getNumber')},
      url: '/api/phone_verification/send_code.json',
      cache: false,
      success: function (data) {
        displayStatusMessage(data.message);
        $verificationCodeInput.prop('disabled', false);
      },
      error: function (error) {
        console.log(error);
        displayStatusMessage(error.responseJSON.message);
      }
    });
  });

  $verificationCodeInput.on('keyup', function () {
    // Filter non-digits from input value.
    if (/\D/g.test(this.value)) {
      this.value = this.value.replace(/\D/g, '');
    }

    var verificationCodeLength = $(this).val().length,
        isValid = verificationCodeLength == i18n.params.verificationCodeLength,
        message = i18n.errors.error;

    if (isValid) {
      message = i18n.messages.numberValidReadyForSendingCode;
    } else {
      if (verificationCodeLength < i18n.params.verificationCodeLength) {
        message += i18n.errors.verificationCodeTooShort
      } else if (verificationCodeLength > i18n.params.verificationCodeLength) {
        message += i18n.errors.verificationCodeTooLong
      }
    }
    enableButton($verifyCodeButton, isValid);
    displayStatusMessage(message);
  });

  $verifyCodeButton.on('click', function () {
    $.ajax({
      type: 'POST',
      dataType: 'json',
      data: {verification_code: $verificationCodeInput.val()},
      url: '/api/phone_verification/verify_code.json',
      cache: false,
      success: function (response) {
        displayStatusMessage(response.message);
        displayElement($numberVerifiedBadge, true);
        enableButton($sendCodeButton, false);
        $cancelVerificationButton.click();
      },
      error: function (response) {
        displayStatusMessage(response.responseJSON.message);
        disableSendCodeButtonForCooldown();
      }
    });
  });

  $cancelVerificationButton.on('click', function () {
    displayElement($statusMessage, false);
    displayStatusMessage('');
    displayElement($('#input-code-row'), false);
    $verificationCodeInput.val('');
    $verificationCodeInput.prop('disabled', true);
    enableButton($verifyCodeButton, false);
  });

  // Edit profile form submit.
  $('#edit_profile_form').submit(function () {
    $phoneNumberInput.val($phoneNumberInput.intlTelInput('getNumber'));
  });

  // Profile photo - Init Image Uploader
  var imagesUploadWiz = (function () {
    var moduleWrap, imageBlock;
    return {
      fileReaderHandler: function (input) {
        if (input.files && input.files[0]) {
          var reader = new FileReader();
          reader.onload = function (e) {
            $('.photos-content .loadImage').attr('src', e.target.result).hide().fadeIn(650);
            $('.avatar img').attr('src', e.target.result).hide().fadeIn(650);
            $('#remove-avatar-button').fadeIn(650);
          };
          reader.readAsDataURL(input.files[0]);
        } else {
          return false;
        }
      },
      inputOnChange: function () {
        $(moduleWrap).on('change', '.inputImg', function (e) {
          var form = $(this).parents('form');

          // To avoid submit empty `params[:user][:image]` in AJAX to server.
          if (!imagesUploadWiz.fileReaderHandler(this)) {
            return false;
          }

          // After form submit /gems/remotipart-1.4.2/vendor/assets/javascripts/jquery.remotipart.js:57
          // sets `disabled` to `input.inputImg`" type="file" and prevent further uploads.
          form.submit();
          // Remove `disabled` to enable uploading.
          $('.inputImg').prop('disabled', false)
        });
      },
      getCurrentBlock: function (item) {
        return $(item).parents(imageBlock);
      },
      init: function (setModuleWrap, setImageBlock) {
        moduleWrap = setModuleWrap;
        imageBlock = setImageBlock;
        this.inputOnChange();
      }
    }
  })();
  imagesUploadWiz.init('.jsWrap', '.image-group');

  // Remove avatar button
  $('#remove-avatar-button').on('click', function () {
    var $url = $(this).data('url'),
        $default_image = $(this).data('default-image'),
        $deleted_message = $(this).data('deleted-message'),
        $image_container = $('.loadImage'),
        $remove_avatar_button = $(this);

    $.ajax({
      type: 'DELETE',
      dataType: 'json',
      data: {},
      url: $url,
      success: function () {
        $image_container.attr('src', $default_image).hide().fadeIn(650);
        $('.avatar img').attr('src', $default_image).hide().fadeIn(650);
        $remove_avatar_button.fadeOut(650);
        // TODO: displayFlashMessage($deleted_message);
        $('#flash_messages').prepend('<div class="alert alert-alert"><div class="alert-text">'
          + $deleted_message
          + '</div><button class="alert-close button btn-negative">Close</button></div>');
        slowFlashHide();
        $("#user_image").val("");
      },
      error: function (error) {
        console.log(error);
      }
    });
  });

  // Trust and verification
  $('.omniauth-connect-switcher-label').on('click', function () {
    var $disconnected_label = $(this).data('disconnected-label'),
        $disconnected_message = $(this).data('disconnected-message'),
        $connected_label = $(this).data('connected-label'),
        $redirect_url = $(this).data('connect'),
        $provider = $(this).data('provider');

    if ($(this).siblings().prop('checked')) {
      $(this).text($disconnected_label);

      $.ajax({
        type: 'PATCH',
        dataType: 'json',
        data: {},
        url: '/api/disconnect_' + $provider + '.json',
        success: function () {
          // TODO: displayFlashMessage($disconnected_message, '#flash_messages');
          $('#flash_messages').prepend('<div class="alert alert-alert"><div class="alert-text">'
            + $disconnected_message
            + '</div><button class="alert-close button btn-negative">Close</button></div>');
          slowFlashHide();
        },
        error: function (error) {
          console.log(error);
        }
      });
    } else {
      $(this).text($connected_label);

      location.assign($redirect_url);
    }
  });

  // User profile page, send report about user.
  $('#send-user-report-button').on('click', function () {

    if(false) {
      var $report_button = $('#report-user-button'),
          target_user_id = $report_button.data('user-id'),
          reported_message = $report_button.data('reported-message'),
          details = $('#report-user-modal textarea#details').val(),
          reason_id = $('input[name="report_reason"]:checked').val();

      $.ajax({
        type: 'POST',
        dataType: 'json',
        data: {
          target_user_id: target_user_id,
          reason_id: reason_id,
          details: details
        },
        url: '/api/reports/about_user.json',
        cache: false,
        success: function () {
          displayFlashMessage(reported_message);
        },
        error: function (error) {
          console.log(error);
        }
      });

      // $('#report_reason_4').prop('checked', true);
      if($('.report-reason-box.active').length) {
        $('.report-reason-box.active').find(".report-reason-content").slideUp();
        $('.report-reason-box.active').removeClass("active");
      };
      $('#details').val("");
      $(".report-reasons-container").removeClass("rs-finish-page");
      $(".report-reason-section").hide();
      $('#report-user-modal').modal('hide');

    } else {



    }

  });

  function skipDesc() {
    var arr = [7, 8]
    var rn = parseInt($('input[name="report_reason"]:checked').val());
    return arr.indexOf(rn) !== -1;
  };

  function sendReport() {
    var $report_button = $('#report-user-button'),
    target_user_id = $report_button.data('user-id'),
    reported_message = $report_button.data('reported-message'),
    details = $('#report-user-modal textarea#details').val(),
    reason_id = $('input[name="report_reason"]:checked').val();

    $.ajax({
      type: 'POST',
      dataType: 'json',
      data: {
        target_user_id: target_user_id,
        reason_id: reason_id,
        details: details
      },
      url: '/api/reports/about_user.json',
      cache: false,
      success: function () {
        displayFlashMessage(reported_message);
      },
      error: function (error) {
        console.log(error);
      }
    });

    $('#details').val("");
    $(".report-reason-section").hide();
    $(".rs-page.active").removeClass("active");
    $(".rs-page:first-child").addClass("active");
    $(".modal-dialog .buttons").attr("class", "buttons pg1");
    $('#report-user-modal').modal('hide');
  };


  // Report popups
  $(".btn-reason-prev").on("click", function(e){
    e.preventDefault();
    $a = $(".rs-page.active");
    $x = $a.prev();
    if($x.length > 0){
      $x.add($a).toggleClass('active');
    };

    var currentStage = parseInt($(".rs-page.active").data("stage"));
    $(".modal-dialog .buttons").attr("class", "buttons pg" + currentStage);

    if(currentStage === 1){
      $(".report-reason-section").hide();
    };

  });

  $(".btn-reason-next").on("click", function(e){
    e.preventDefault();
    $a = $(".rs-page.active");
    $x = $a.next();
    if($x.length > 0){
      $x.add($a).toggleClass('active');
    } else {
      sendReport();
    };

    var currentStage = parseInt($(".rs-page.active").data("stage"));
    $(".modal-dialog .buttons").attr("class", "buttons pg" + currentStage);

    if(currentStage === 2){
      var sectionNumber = $(".report-reason-title input:checked").val();
      $("#rs" + sectionNumber + " .report-reason-check:first input").prop("checked", true);
      $("#rs" + sectionNumber).show();
    };

    if(currentStage === 3){
      if(skipDesc()) {
        sendReport();
      }
    };

  });


});
