//= require ../application

// To top wizard page after changing wizard page (at mobile)
function wizardScrollTop() {
    var heightHeader = 213;
    if ($('#boat_wizard_progress').val() == 1) {
        heightHeader = 93;
    } else if ($('#boat_wizard_progress').val() == 13 || $('#boat_wizard_progress').val() == 19) {
        heightHeader = 142;
    }
    ;
    if ($(window).width() < 481) {
        $("html, body").animate({
                scrollTop: heightHeader
            }, 500
        );
    }
};

function updateMinStayInputs() {
    var minimumStay = $("#boat_season_rates_attributes_0_minimum_stay").val();
    switch(minimumStay) { 
        case "86400":
        case "172800":
        case "259200":
        case "345600":
        case "432000":
        case "518400":
            // minimum stay is higher than half a day
            $('#boat_season_rates_attributes_0_per_half_day').prop('disabled', 'disabled');
            $('#boat_season_rates_attributes_0_per_half_day').addClass('disabled');
            $('#boat_season_rates_attributes_0_per_half_day').val('');

            $('#boat_season_rates_attributes_0_per_day').prop('disabled', false);
            $('#boat_season_rates_attributes_0_per_day').removeClass('disabled');
            $('#boat_season_rates_attributes_0_per_night').prop('disabled', false);
            $('#boat_season_rates_attributes_0_per_night').removeClass('disabled');
            $('#boat_season_rates_attributes_0_per_week').prop('disabled', false);
            $('#boat_season_rates_attributes_0_per_week').removeClass('disabled');                
            break;
        case "604800":
        case "1209600":
        case "1814400":
            // minimum stay is higher than one week day
            $('#boat_season_rates_attributes_0_per_half_day').prop('disabled', 'disabled');
            $('#boat_season_rates_attributes_0_per_half_day').addClass('disabled');
            $('#boat_season_rates_attributes_0_per_half_day').val('');
            $('#boat_season_rates_attributes_0_per_day').prop('disabled', 'disabled');
            $('#boat_season_rates_attributes_0_per_day').addClass('disabled');
            $('#boat_season_rates_attributes_0_per_day').val('');
            $('#boat_season_rates_attributes_0_per_night').prop('disabled', 'disabled');
            $('#boat_season_rates_attributes_0_per_night').addClass('disabled');
            $('#boat_season_rates_attributes_0_per_night').val('');
            break;
        default:
            $('#boat_season_rates_attributes_0_per_half_day').prop('disabled', false);
            $('#boat_season_rates_attributes_0_per_half_day').removeClass('disabled');
            $('#boat_season_rates_attributes_0_per_day').prop('disabled', false);
            $('#boat_season_rates_attributes_0_per_day').removeClass('disabled');
            $('#boat_season_rates_attributes_0_per_night').prop('disabled', false);
            $('#boat_season_rates_attributes_0_per_night').removeClass('disabled');
            $('#boat_season_rates_attributes_0_per_week').prop('disabled', false);
            $('#boat_season_rates_attributes_0_per_week').removeClass('disabled');
    }
}   

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

$(document).ready(function () {
    
    updateMinStayInputs();

    $("#tab-count").val($(".nested-fields").length);
    calcStylesTab();

    $('#season_rates')
        .on('cocoon:before-insert', function () {
        })
        .on('cocoon:after-insert', function () {
            $('.select2').select2();
            //$('.nested-fields:last .btn-switcher').html('S ' + nfcounter);
            //nfcounter++;
            var tmp_nfc = $('#tab-count').val();
            tmp_nfc++;
            $('#tab-count').val(tmp_nfc);

            $('.nested-fields.active').removeClass('active');
            $('.nested-fields:last').addClass('active');


            var calendarFrom = $('.nested-fields.active .dt-season-from'),
            calendarUntil = $('.nested-fields.active .dt-season-until');
            calendarFrom.datepicker({
                format: 'yyyy-mm-dd',
                autoclose: true,
            });
            calendarUntil.datepicker({
                format: 'yyyy-mm-dd',
                autoclose: true,
            });
            calendarFrom.on('changeDate', function () {
                calendarUntil.val('');
                var tesr = calendarFrom.datepicker('getDate');
                //tesr.setDate(tesr.getDate()+1); //shift to one day
                calendarUntil.datepicker('setStartDate', tesr);
            });
            calendarUntil.on('changeDate', function () {

                var startNF = calendarFrom.datepicker('getDate');
                var endNF = $(this).datepicker('getDate');

                $(this).parents('.nested-fields').find('.date-range-val').val(getDates(startNF, endNF));

                var sumRange = new Array;
                $('.nested-fields .date-range-val').each(function () {
                    if ($(this).val() != '') {
                        var afg = new Array;
                        afg = $(this).val().split(',');
                        sumRange = sumRange.concat(afg);
                        $.each(sumRange, function (index, date_string) {
                            var date = new Date(date_string);
                            date.setHours(0, -date.getTimezoneOffset(), 0, 0);
                            sumRange[index] = date.toISOString().slice(0, 10);
                        });
                    }
                });

                $('.nested-fields:not(.active) .datepicker-season').datepicker('setDatesDisabled', sumRange);
            });

            calcStylesTab();

            var sumRange = new Array;
            $('.nested-fields .date-range-val').each(function () {
                if ($(this).val() != '') {
                    var afg = new Array;
                    afg = $(this).val().split(',');
                    sumRange = sumRange.concat(afg);
                    $.each(sumRange, function (index, date_string) {
                        var date = new Date(date_string);
                        date.setHours(0, -date.getTimezoneOffset(), 0, 0);
                        sumRange[index] = date.toISOString().slice(0, 10);
                    });
                }
            });
            $('.nested-fields.active .datepicker-season').datepicker('setDatesDisabled', sumRange);

        })
        .on("cocoon:before-remove", function () {
            var tmp_nfc = $('#tab-count').val();
            tmp_nfc--;
            $('#tab-count').val(tmp_nfc);

            var sumRange = new Array;
            $('.nested-fields:not(.active) .date-range-val').each(function () {
                if ($(this).val() != '') {
                    var afg = new Array;
                    afg = $(this).val().split(',');
                    sumRange = sumRange.concat(afg);
                    $.each(sumRange, function (index, date_string) {
                        var date = new Date(date_string);
                        date.setHours(0, -date.getTimezoneOffset(), 0, 0);
                        sumRange[index] = date.toISOString().slice(0, 10);
                    });
                }
            });
            $('.nested-fields:not(.active) .datepicker-season').datepicker('setDatesDisabled', sumRange);

        })
        .on("cocoon:after-remove", function () {
            $('.nested-fields:last').addClass('active');
            calcStylesTab();
        });

    var currentStage = $('#boat_wizard_progress'),
        statusLine = $('.status-line'),
        page = $('.wizard-page');

    //set visible target page and other attributes
    set_target_page(currentStage);

    // Wizard Validation 
    var emptyTextMessage = $("#emptyTextMessage").val(),
        emptyTextareaMessage = $("#emptyTextareaMessage").val(),
        emptyNumberMessage = $("#emptyNumberMessage").val(),
        emptySelectMessage = $("#emptySelectMessage").val(),
        emptyPositionMessage = $("#emptyPositionMessage").val(),
        maximumBoatLengthVal = $("#maximumBoatLengthVal").val(),
        maxAndMinBoatYearOfConstructionVal = $("#maxAndMinBoatYearOfConstructionVal").val(),
        maximumCabinsVal = $("#maximumCabinsVal").val(),
        maximumBedsVal = $("#maximumBedsVal").val(),
        maximumGuestVal = $("#maximumGuestVal").val(),
        maximumBathroomsVal = $("#maximumBathroomsVal").val(),
        maximumBoatListingTitleVal = $("#maximumBoatListingTitleVal").val(),
        alphanumericBoatListingTitleVal = $("#alphanumericBoatListingTitleVal").val(),
        notOnlyIntegerBoatListingTitleVal = $("#notOnlyIntegerBoatListingTitleVal").val(),  
        perDayMinValMessage = $("#perDayMinValMessage").val(),
        perNightMinValMessage = $("#perNightMinValMessage").val(),
        perWeekMinValMessage = $("#perWeekMinValMessage").val(),

        latValueField = $('#lat-value'),
        lngValueField = $('#lng-value');

    function wizardValidation() {
      var pageActive = $('.wizard-page:not(.hidden)');
      if (!pageActive.find('input[type="text"]').length == 0) {
        var inputText = pageActive.find('input[type="text"]:not(.disabled, .season-rate-price)');

        inputText.each(function () {
          if ($(this).val() == '') {
            if (($(this).parent().find('.field-error').length == 0)) {
              $(this).parent().append('<span class="field-error">' + emptyTextMessage + '</span>');
            }
            $(this).addClass('input-error');
          } else {
            $(this).siblings('.field-error').detach();
            $(this).removeClass('input-error');
          }
        });

        // Season rates prices group validation: at least one price filled.
        var seasonRatesTabs = pageActive.find('#season_rates div.nested-fields');
        seasonRatesTabs.each(function () {
          var seasonRatesInputs = $(this).find('input[type="text"]:not(.disabled).season-rate-price');

          if ($(seasonRatesInputs[0]).val() === '' &&
              $(seasonRatesInputs[1]).val() === '' &&
              $(seasonRatesInputs[2]).val() === '' &&
              $(seasonRatesInputs[3]).val() === '') {
            seasonRatesInputs.each(function () {
              $(this).addClass('input-error');
              if (($(this).parent().find('.field-error').length === 0)) {
                $(this).parent().append('<span class="field-error">' + emptyTextMessage + '</span>');
              }
            })
          } else {
            seasonRatesInputs.each(function () {
              $(this).removeClass('input-error');
              $(this).siblings('.field-error').detach();
            })
          }
        })
      };

        if (!pageActive.find('input[type="text"]').length == 0) {
            var inputTextDisabled = pageActive.find('input[type="text"]');
            inputTextDisabled.each(function () {
                if ($(this).hasClass('disabled')) {
                    $(this).siblings('.field-error').detach();
                    $(this).removeClass('input-error');
                }
            });
        };

        if ((!pageActive.find('#boat_season_rates_attributes_0_per_half_day').length == 0) &&
            (!$('#boat_season_rates_attributes_0_per_half_day').not(':disabled').length == 0)    
        ) {
            input = $('#boat_season_rates_attributes_0_per_half_day');
            if (input.val() === '') {
                if ((input.parent().find('.field-error').length == 0)) {
                    input.parent().append('<span class="field-error">' + emptyNumberMessage + '</span>');
                }
            }
        };        

        if ((!pageActive.find('#boat_season_rates_attributes_0_per_day').length == 0) &&
            (!$('#boat_season_rates_attributes_0_per_day').not(':disabled').length == 0)    
        ) {
            input = $('#boat_season_rates_attributes_0_per_day');
            if (input.val() === '') {
                if ((input.parent().find('.field-error').length == 0)) {
                    input.parent().append('<span class="field-error">' + emptyNumberMessage + '</span>');
                }
            } else if (parseInt(input.val()) < parseInt($('#boat_season_rates_attributes_0_per_half_day').val())) {
                if ((input.parent().find('.field-error').length == 0)) {
                    input.parent().append('<span class="field-error" style="top: 70px">' + perDayMinValMessage + '</span>');
                }                
            }
        };

        if ((!pageActive.find('#boat_season_rates_attributes_0_per_night').length == 0) &&
            (!$('#boat_season_rates_attributes_0_per_night').not(':disabled').length == 0)    
        ) {
            input = $('#boat_season_rates_attributes_0_per_night');
            if (input.val() === '') {
                if ((input.parent().find('.field-error').length == 0)) {
                    input.parent().append('<span class="field-error">' + emptyNumberMessage + '</span>');
                }
            } else if (parseInt(input.val()) < parseInt($('#boat_season_rates_attributes_0_per_day').val())) {
                if ((input.parent().find('.field-error').length == 0)) {
                    input.parent().append('<span class="field-error" style="top: 100px">' + perNightMinValMessage + '</span>');
                }                
            }
        };
        
        if ((!pageActive.find('#boat_season_rates_attributes_0_per_week').length == 0) &&
            (!$('#boat_season_rates_attributes_0_per_week').not(':disabled').length == 0)    
        ) {
            input = $('#boat_season_rates_attributes_0_per_week');
            if (input.val() === '') {
                if ((input.parent().find('.field-error').length == 0)) {
                    input.parent().append('<span class="field-error">' + emptyNumberMessage + '</span>');
                }
            } else if (parseInt(input.val()) < parseInt($('#boat_season_rates_attributes_0_per_night').val())) {
                if ((input.parent().find('.field-error').length == 0)) {
                    input.parent().append('<span class="field-error" style="top: 70px">' + perWeekMinValMessage + '</span>');
                }                
            }
        };        

        
        if (!pageActive.find('#boat_listing_title').length == 0) {
            var only_integer = new RegExp('^[0-9]+$');

            if (only_integer.test($("#boat_listing_title").val()) ){
                $("#boat_listing_title").parent().append('<span class="field-error">' + notOnlyIntegerBoatListingTitleVal + '</span>');
            } else if ($("#boat_listing_title").val().length > 64){
                $("#boat_listing_title").parent().append('<span class="field-error">' + maximumBoatListingTitleVal + '</span>');
            }                        
        };


        if (!pageActive.find('textarea').length == 0) {
            var textarea = pageActive.find('textarea');
            textarea.each(function () {
                if ($(this).val() == '') {
                    if (($(this).parent().find('.field-error').length == 0)) {
                        $(this).parent().append('<span class="field-error">' + emptyTextareaMessage + '</span>');
                    };
                    $(this).addClass('input-error');
                } else {
                    $(this).siblings('.field-error').detach();
                    $(this).removeClass('input-error');
                }
            });
        }
        ;

        if (!pageActive.find('select').length == 0) {
            var select = pageActive.find('select');
            select.each(function () {
                if ($(this).val() == '') {
                    if (($(this).parent().find('.field-error').length == 0)) {
                        $(this).parent().append('<span class="field-error">' + emptySelectMessage + '</span>');
                    }
                    ;
                    $(this).addClass('input-error');
                } else {
                    $(this).siblings('.field-error').detach();
                    $(this).removeClass('input-error');
                }
            });
        }
        ;

        if (!pageActive.find('input[type="number"]').length == 0) {
            var inputNumber = pageActive.find('input[type="number"]:not(.disabled):not(.not-validate)');
            inputNumber.each(function () {
                if ($(this).val() == '') {
                    if (($(this).parent().find('.field-error').length == 0)) {
                        $(this).parent().append('<span class="field-error">' + emptyNumberMessage + '</span>');
                    }
                    ;
                    $(this).addClass('input-error');
                } else {
                    $(this).siblings('.field-error').detach();
                    $(this).removeClass('input-error');
                }
            });
        }


        if (!pageActive.find('#boat_cabins_count').length == 0) {
            if ($("#boat_cabins_count").val() > 50){
                $("#boat_cabins_count").parent().append('<span class="field-error">' + maximumCabinsVal + '</span>');
            }
        
        };
        if (!pageActive.find('#boat_beds_count').length == 0) {
            if ($("#boat_beds_count").val() > 50){
                $("#boat_beds_count").parent().append('<span class="field-error">' + maximumBedsVal + '</span>');
            }
        
        };
        if (!pageActive.find('#boat_guest_number').length == 0) {
            if ($("#boat_guest_number").val() > 100){
                $("#boat_guest_number").parent().append('<span class="field-error">' + maximumGuestVal + '</span>');
            }
        
        };
        if (!pageActive.find('#boat_bathrooms_count').length == 0) {
            if ($("#boat_bathrooms_count").val() > 20){
                $("#boat_bathrooms_count").parent().append('<span class="field-error">' + maximumBathroomsVal + '</span>');
            }
        
        };

        if (!pageActive.find('input[type="tel"]').length == 0) {
            var inputTel = pageActive.find('input[type="tel"]');
            inputTel.each(function () {
                if ($(this).val() == '') {
                    if (($(this).parent().find('.field-error').length == 0)) {
                        $(this).parent().append('<span class="field-error">' + emptyNumberMessage + '</span>');
                    }
                    ;
                    $(this).addClass('input-error');
                } else {
                    $(this).siblings('.field-error').detach();
                    $(this).removeClass('input-error');
                }
            });
        }
        ;

        if (!pageActive.find('#boat_length').length == 0) {
            var only_float = new RegExp('^[+-]?([0-9]*[.])?[0-9]+$');
            if ($('#boat_length').val() > 100){
                $('#boat_length').parent().append('<span class="field-error">' + maximumBoatLengthVal + '</span>');
            }
            // if ($('#boat_length').val() < 0){
                // posit = ($('#boat_length').val()) * -1;
                // $('#boat_length').val(posit);
            // }

        };
        if (!pageActive.find('#boat_year_of_construction').length == 0) {
            var onlyInteger = new RegExp('^[0-9]+$');
            var currentYear = new Date().getFullYear();
            var yearOfConstruction = $('#boat_year_of_construction').val();

            if (onlyInteger.test(yearOfConstruction) ) {
                if ((yearOfConstruction < 1900) || (yearOfConstruction > currentYear)) {
                    $('#boat_year_of_construction').parent().append('<span class="field-error">' + maxAndMinBoatYearOfConstructionVal + '</span>');
                }
            }
            
        };
       

        if (!pageActive.find('#pac-input').length == 0) {
            if (latValueField.val() == '' || lngValueField.val() == '') {
                if ((latValueField.parent().find('.field-error').length == 0)) {
                    latValueField.parent().append('<span class="field-error">' + emptyPositionMessage + '</span>');
                };
                $('#pac-input').addClass('input-error');
            } else {
                latValueField.siblings('.field-error').detach();
                $('#pac-input').removeClass('input-error');
            }
        }
        ;

    }

    // Wizard Listing
  $(document).on('click', '#btn-save-exit', function () {
    $('#save_and_exit').val(true);

    // Allow to submit form for 10 (phone verification) and 15 (seasonal rates).
    if ('[10 15]'.indexOf($('#boat_wizard_progress').val()) > 0) {
      $('#wizard_form').submit();
    } else {
      wizardValidation();
      if ($('body').find('.field-error').length == 0) {
        $('#wizard_form').submit();
      }
    }
  });

    // == Verify phone number via SMS code wizard stage ==
    // TODO: Replace this custom i18n with Rails -> JS via gem.
    const i18n = {
        messages: {
            numberValidReadyForSendingCode: 'Number valid, ready for sending code.'
        },
        errors: {
            error: 'Error: ',
            numberIsIncorrect: 'the number is incorrect.',
            numberIsTooShort: 'the number is too short.',
            numberIsTooLong: 'the number is too long.',
            numberIsNotANumber: 'the number is not a number.',
            verificationCodeTooShort: 'verification code too short.',
            verificationCodeTooLong: 'verification code too long.'
        },
        params: {
            verificationCodeLength: 5,
            verificationCodeCooldown: 60
        }
    };
    var $phoneNumberInput = $('#phone-number-input'),
        $sendCodeButton = $('#send-code-button'),
        $verificationCodeInput = $('#verification-code-input'),
        $verifyCodeButton = $('#verify-code-button'),
        $statusMessage = $('#status-message');

    function enableButton(jQueryButton, enabled) {
        jQueryButton.prop('disabled', !enabled);
        enabled ? jQueryButton.removeClass('btn-disabled') : jQueryButton.addClass('btn-disabled');
    }

    function displayElement(jQueryElement, displayed) {
        displayed ? jQueryElement.removeClass('hidden') : jQueryElement.addClass('hidden');
        // if(displayed) {
        //   jQueryElement.removeClass('hidden');
        //   jQueryElement.show();
        // } else {
        //   jQueryElement.addClass('hidden');
        //   jQueryElement.hide();
        // }
    }

    function displayStatusMessage(message) {
        $statusMessage.text(message);
    }

    function disableSendCodeButtonForCooldown() {
        enableButton($sendCodeButton, false);
        window.setTimeout(function () {
            enableButton($sendCodeButton, true);
        }, i18n.params.verificationCodeCooldown * 1000);
    }

    // Init Intl Tel Input (International Telephone Input)
    $phoneNumberInput.intlTelInput({
        preferredCountries: ["es", "gb", "fr", "de", "it", "nl"]
      }).done(function () {
        $phoneNumberInput.on('keyup', function () {
            // Filter non-digits from input value.
            if (/\D/g.test(this.value)) {
                this.value = this.value.replace(/\D/g, '');
            }

            var isValidNumber = $(this).intlTelInput('isValidNumber'),
                validationError = $(this).intlTelInput('getValidationError'),
                message = i18n.errors.error;

            if (isValidNumber) {
                message = i18n.messages.numberValidReadyForSendingCode;
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
                        message += i18n.errors.numberIsNotANumber;
                        break;
                    default:
                        message += i18n.errors.numberIsIncorrect;
                        break;
                }
            }
            enableButton($sendCodeButton, isValidNumber);
            displayStatusMessage(message);
            displayElement($('#status-message-row'), true);
        });
    });

    // Button for sending SMS with verification code.
    $sendCodeButton.on('click', function () {
        $.ajax({
            type: 'POST', // 'GET'
            dataType: 'json',
            data: {phone_number: $phoneNumberInput.intlTelInput('getNumber')},
            url: '/api/phone_verification/send_code.json',
            cache: false,
            success: function (data) {
                displayStatusMessage(data.message);
                $verificationCodeInput.prop('disabled', false);
                disableSendCodeButtonForCooldown();
            },
            error: function (error) {
                console.log(error);
                displayStatusMessage(error.responseJSON.message);
            }
        });
    });

    // Button for sending verification code received from SMS.
    $verificationCodeInput.on('keyup', function (event) {
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
                $phoneNumberInput.prop('disabled', true);
                $verificationCodeInput.prop('disabled', true);
                enableButton($sendCodeButton, false);
                enableButton($verifyCodeButton, false);
            },
            error: function (response) {
                displayStatusMessage(response.responseJSON.message);
                disableSendCodeButtonForCooldown();
            }
        });
    });
    // == Verify phone number wizard stage ==

    // Wizard Status Line
    function lineUpdating() {
        statusLine.find('.progress').css('width', (currentStage.val() / 20 * 100 + '%'))
        if (currentStage.val() == 1 || currentStage.val() == 8) {
            statusLine.hide();
        } else {
            statusLine.show();
        }
    };
    lineUpdating();

    // Wizard Status Text
    function textUpdating() {
        $('#status-text').html($('.wizard-page:not(.hidden) .status-text-val').val())
    };

    // Wizard Back Step
    $(document).on('click', '.back', function () {
        var stage = parseInt($(this).attr('data-stage'));
        var commit = $(this).attr('data-commit');
        var backurl = $(this).attr('data-backurl');
        var next_stage = stage - 1;

        if (stage == 1) {
            location.href = backurl;
            return false;
        }

        $("div[data-stage=" + stage + "]").addClass('hidden');
        $("div[data-stage=" + next_stage + "]").removeClass('hidden');

        $('#boat_wizard_progress').val(next_stage);

        if (next_stage > 1) {
            $('#btn-save-exit').show();
        } else {
            $('#btn-save-exit').hide();
        }

        lineUpdating();
        textUpdating();
        wizardScrollTop();
    });

    // Wizard Next Step
    $(document).on('click', '.next', function () {
        wizardValidation();
        if ($('.wizard-page:not(.hidden)').find('.field-error').length == 0) {
            var stage = parseInt($(this).attr('data-stage'));
            var commit = $(this).attr('data-commit');
            var backurl = $(this).attr('data-backurl');
            var next_stage = stage + 1;

            $("div[data-stage=" + stage + "]").addClass('hidden');
            $("div[data-stage=" + next_stage + "]").removeClass('hidden');

            $('#boat_wizard_progress').val(next_stage);

            if (next_stage > 1) {
                $('#btn-save-exit').show();
            } else {
                $('#btn-save-exit').hide();
            }

            // Front: Submit form, Back: create listing, redirect to edit.
            if ($('#action').val() === 'new' && stage === 7) {
                $('#wizard_form').submit();
            }

            // Submit form on stage with uploading photos to validate early.
            // if (stage === 12) {
            //   $('#wizard_form').submit();
            // }

            // Final stage.
            if (stage === 19) {
                $('#save_and_exit').val(true);
                $('#wizard_form').submit();
            }

            lineUpdating();
            textUpdating();
            wizardScrollTop();
        }
    });

  function resetInvalidSeasonalRates() {
    $('#season_rates .input-error').each(function () {
      $(this).removeClass('input-error').siblings('.field-error').detach();
    });
  }

  // Wizard Skip Step (may be refactoring)
  $(document).on('click', '.btn-skip', function () {
    var stage = parseInt($(this).attr('data-stage')),
        next_stage = stage + 1;

    stage === 15 && resetInvalidSeasonalRates();

    $('div[data-stage=' + stage + ']').addClass('hidden');
    $('div[data-stage=' + next_stage + ']').removeClass('hidden');
    $('#boat_wizard_progress').val(next_stage);

    // Front: Submit form, Back: create listing, redirect to edit.
    if ($('#action').val() === 'new' && stage === 7) {
      $('#wizard_form').submit();
    }

    lineUpdating();
    textUpdating();
    wizardScrollTop();
  });

    // Textarea counter
    var text = $('textarea.with-counter'),
        maxCount = 500;
    text.parent().append('<span class="textarea-counter">' + maxCount + '</span>');
    $(text).keyup(function () {
        var count = $(this).val().length;
        $(this).siblings('.textarea-counter').html(maxCount - count);
    });

    // Additional feels Switcher
    $('.additional-feels input[type="checkbox"]').on('change', function () {
        var _ident = '#boat_' + $(this).attr('id');
        $(_ident).toggleClass('disabled');
        $(_ident).val('');
        if ($(_ident).hasClass('disabled')) {
            $(_ident).removeClass('input-error');
        }
    });

    // `I agree the terms` checkbox that switch enabling of `Finish` button on
    // final stage 19.
    $('input[type="checkbox"]#agree').on('change', function () {
        // NOTE: This code `!$(this).prop('checked')` in `toggleClass` is for
        // fix bug when checkbox + button work in antiphase.
        $('#page-final03 .btn-finish').toggleClass('btn-disabled', !$(this).prop('checked'))
    });

    // Wizard Calendar
    function datesCleaning(strDates) {
        return strDates.replace(/^[,\s]+|[,\s]+$/g, '').replace(/,[,\s]*,/g, ',');
    };
    if (!$('.bw-calendar').length == 0) {

        var calendar = $('.bw-calendar'),
            buttonLock = $('.btn-locking'),
            buttonUnLock = $('.btn-unlocking'),

            datesSelected = $('#bw-calendar-val'),
            datesLocked = $('#bw-calendar-val-locked'),
            datesLockedHard = $('#bw-calendar-val-locked-hard'),
            datesLockedStorage = $('#bw-calendar-val-locked-storage'),

            datesSelectedArray,
            datesLockedArray,
            datesLockedHardArray,
            datesLockedStorageArray;

        datesSelectedArray = [];
        datesLockedArray = [];
        datesLockedHardArray = [];
        datesLockedStorageArray = [];

        var datesDisabled = [];
        var bookingsDate = calendar.data("bookings");
        var blockedDate = calendar.data("booking-blockings");
        bookingsDate.map(function(item){
            datesDisabled = datesDisabled.concat(getStringDates(item.check_in, item.check_out))
        });
        blockedDate.map(function(item){
          datesDisabled = datesDisabled.concat(getStringDates(item.started_at, item.finished_at))
        });
        datesLockedHard.val(datesDisabled);

        datesLockedHardArray = datesLockedHard.val().split(',');

        calendar.datepicker({
          format: 'yyyy-mm-dd',
          multidate: true,
          startDate: new Date(),
          datesDisabled: datesLockedHardArray,
          todayHighlight: true
        });

        calendar.on('changeDate', function () {
            datesSelected.val(
                calendar.datepicker('getFormattedDate')
            );
        });

        buttonLock.click(function (e) {
            e.preventDefault();
            var tempDates = datesSelected.val() + ',' + datesLocked.val();
            datesLocked.val(datesCleaning(tempDates));

            datesLockedStorage.val(datesLocked.val());

            datesLockedArray = datesLocked.val().split(',');
            calendar.datepicker('setDatesDisabled', datesLockedArray.concat(datesLockedHardArray));

            $(this).hide();
        });

        buttonUnLock.click(function (e) {
            e.preventDefault();
            // var tempDates = datesLocked.val();
            // datesLocked.val(datesCleaning(tempDates));

            datesLocked.val(datesCleaning(datesLockedStorage.val()));

            datesLockedArray = datesLocked.val().split(',');
            calendar.datepicker('setDatesDisabled', datesLockedArray.concat(datesLockedHardArray));

            $(this).hide();
        });

        calendar.on('mousedown', 'td:not(.disabled)', function () {
            buttonLock.show();
            buttonUnLock.hide();
        });

        calendar.on('mousedown', 'td.disabled-date:not(.activated)', function () {
            buttonLock.hide();
            buttonUnLock.show();

            var pickYear = $('.datepicker-days .datepicker-switch').text().substr(-4, 4),
                pickMonth = $('.datepicker-days .datepicker-switch').text().split(' ')[0],
                pickDay = $(this).text(),
                pickDate,
                tempDates;
            switch (pickMonth) {
                case 'January':
                    pickMonth = 1;
                    break;
                case 'February':
                    pickMonth = 2;
                    break;
                case 'March':
                    pickMonth = 3;
                    break;
                case 'April':
                    pickMonth = 4;
                    break;
                case 'May':
                    pickMonth = 5;
                    break;
                case 'June':
                    pickMonth = 6;
                    break;
                case 'July':
                    pickMonth = 7;
                    break;
                case 'August':
                    pickMonth = 8;
                    break;
                case 'September':
                    pickMonth = 9;
                    break;
                case 'October':
                    pickMonth = 10;
                    break;
                case 'November':
                    pickMonth = 11;
                    break;
                case 'December':
                    pickMonth = 12;
                    break;
                default:
                    pickMonth = 1;
                    break;
            }
            if ($(this).hasClass('old')) {
                pickMonth--;
            }
            if ($(this).hasClass('new')) {
                pickMonth++;
            }
            if (pickMonth < 10) {
                pickMonth = '0' + pickMonth;
            }
            if (pickDay.length == 1) {
                pickDay = '0' + pickDay;
            }
            pickDate = pickYear + '-' + pickMonth + '-' + pickDay

            $(this).addClass('activated');

            //datesLockedStorage.val(datesLocked.val().replace(pickDate,''));

            tempDates = datesLockedStorage.val().replace(pickDate, '');
            datesLockedStorage.val(tempDates);

        });

        calendar.on('mousedown', 'td.disabled-date.activated', function () {

            var pickYear = $('.datepicker-days .datepicker-switch').text().substr(-4, 4),
                pickMonth = $('.datepicker-days .datepicker-switch').text().split(' ')[0],
                pickDay = $(this).text(),
                pickDate,
                tempDates;
            switch (pickMonth) {
                case 'January':
                    pickMonth = 1;
                    break;
                case 'February':
                    pickMonth = 2;
                    break;
                case 'March':
                    pickMonth = 3;
                    break;
                case 'April':
                    pickMonth = 4;
                    break;
                case 'May':
                    pickMonth = 5;
                    break;
                case 'June':
                    pickMonth = 6;
                    break;
                case 'July':
                    pickMonth = 7;
                    break;
                case 'August':
                    pickMonth = 8;
                    break;
                case 'September':
                    pickMonth = 9;
                    break;
                case 'October':
                    pickMonth = 10;
                    break;
                case 'November':
                    pickMonth = 11;
                    break;
                case 'December':
                    pickMonth = 12;
                    break;
                default:
                    pickMonth = 1;
                    break;
            }
            if ($(this).hasClass('old')) {
                pickMonth--;
            }
            if ($(this).hasClass('new')) {
                pickMonth++;
            }
            if (pickMonth < 10) {
                pickMonth = '0' + pickMonth;
            }
            if (pickDay.length == 1) {
                pickDay = '0' + pickDay;
            }
            pickDate = pickYear + '-' + pickMonth + '-' + pickDay

            $(this).removeClass('activated');

            datesLockedStorage.val(datesLocked.val() + ',' + pickDate);

            tempDates = datesLockedStorage.val() + ',' + pickDate;
            datesLockedStorage.val(tempDates);

        });

    }
    ;

    // Init Image Uploader
    var imagesUploadWiz = (function () {
        var moduleWrap, imageBlock;

        return {
            fileReaderHandler: function (input) {
                if (input.files && input.files[0]) {
                    var reader = new FileReader();
                    var loadImage = $(input).parents(imageBlock).find('.loadImage');
                    reader.onload = function (e) {
                        loadImage.attr('src', e.target.result).hide().fadeIn(650);
                    };
                    reader.readAsDataURL(input.files[0]);
                }
            },
            inputOnChange: function () {
                $(moduleWrap).on('change', '.inputImg', function (e) {
                    imagesUploadWiz.fileReaderHandler(this);
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

    // Wizard Tabs
    $('.nested-fields:first').addClass('active');
    function setSizesNF() {
        $('.nf-content').width($('.season_rates_wrapper').width());
        $('.season_rates_wrapper').height($('.nf-content').height());
    };
    $(document).on('click', '.btn-switcher', function (e) {
        e.preventDefault();
        $('.nested-fields.active').removeClass('active');
        $(this).parent().parent().addClass('active');
    });

    $('#season_rates').on('change', '.offer-name', function () {
        if ($(this).val() == 0) {
            $(this).parents('.nested-fields').find('.btn-switcher').text('Season name');
        } else {
            $(this).parents('.nested-fields').find('.btn-switcher').text($(this).val());
        }
    });

    function calcStylesTab() {
        if ($('#tab-count').val() < 4) {
            $('.nf-content').css('top', '7rem');
        }
        ;
        if ($('#tab-count').val() > 3) {
            $('.nf-content').css('top', '9rem');
        }
        ;
        if ($('#tab-count').val() > 6) {
            $('.nf-content').css('top', '11rem');
        }
        ;
    };

    // //Tabs error check
    // function errorTabsChecking() {
    //   $('.field-error').parents('nested-fields:not(.active)')
    //   //.......
    // };

    // Translation func from dates to array
    Date.prototype.addDays = function (days) {
        var date = new Date(this.valueOf());
        date.setDate(date.getDate() + days);
        return date;
    }
    function getDates(startDate, stopDate) {
        var dateArray = new Array();
        var currentDate = startDate;
        while (currentDate <= stopDate) {
            var $tmp = new Date(currentDate);
            dateArray.push($tmp.toISOString());
            currentDate = currentDate.addDays(1);
        }
        return dateArray;
    }

    // Seasons Calendars
    $('.nested-fields').each(function(){

        var calendarFrom = $(this).find('.dt-season-from'),
            calendarUntil = $(this).find('.dt-season-until');
        calendarFrom.datepicker({
            format: 'yyyy-mm-dd',
            autoclose: true,
        });
        calendarUntil.datepicker({
            format: 'yyyy-mm-dd',
            autoclose: true,
        });
        calendarFrom.on('changeDate', function () {
            calendarUntil.val('');
            var tesr = calendarFrom.datepicker('getDate');
            //tesr.setDate(tesr.getDate()+1); //shift to one day
            calendarUntil.datepicker('setStartDate', tesr);
        });
        calendarUntil.on('changeDate', function () {

            var startNF = calendarFrom.datepicker('getDate');
            var endNF = $(this).datepicker('getDate');

            $(this).parents('.nested-fields').find('.date-range-val').val(getDates(startNF, endNF));

            var sumRange = new Array;
            $('.nested-fields .date-range-val').each(function () {
                if ($(this).val() != '') {
                    var afg = new Array;
                    afg = $(this).val().split(',');
                    sumRange = sumRange.concat(afg);
                    $.each(sumRange, function (index, date_string) {
                        var date = new Date(date_string);
                        date.setHours(0, -date.getTimezoneOffset(), 0, 0);
                        sumRange[index] = date.toISOString().slice(0, 10);
                    });
                }
            });

            $('.nested-fields:not(.active) .datepicker-season').datepicker('setDatesDisabled', sumRange);
        });
    });

    $('#wizard_form').addClass('form-loaded');

    // `I agree to use instant booking` checkbox that switch enabling of `Next`
    // button for `boat.instant_booking_classic` on stage 14.
    $('.agree-switcher').on('change', function () {
        $('button#btn-next').toggleClass('btn-disabled', !$(this).prop('checked'))
    });
    // Check instant booking by default
    if (!$('#boat_instant_booking_classic').attr('checked')) {
        $(".agree-switcher").trigger("click");
    }   
});

//set wizard by current stage
function set_target_page(currentStage) {
    current_stage_val = currentStage.val();
    $('div.wizard-page').addClass('hidden');
    $("div.wizard-page[data-stage=" + current_stage_val + "]").removeClass('hidden');

    if (parseInt(current_stage_val) > 1) {
        $('#btn-save-exit').show();
    } else {
        $('#btn-save-exit').hide();
    }
    wizardScrollTop();
};

// Multiple images preview in browser
$(function () {
    var parentPage = $("#page12");
    var getPriority;
    var editReferer = $('.custom-grid-row__referer').data('isRefererEditListing');

    makeImagesSortable();
    var imagesPreview = function (inputItem, placeToInsertImagePreview, dataUrl) {
        var reader = new FileReader();
        reader.fileName = inputItem.name;
        var fileArray = [];

        reader.onload = function (event) {
            var $li = $("<div>", {class: 'thumbnails-item'});

            var $button = $('<button>').attr({
                class: 'remove-btn', // js-remove-new-image',
                type: 'button',
                'data-url': dataUrl
            });

            // TODO: Remove hidden input -> image/button tag `data-priority` attribute.
            var $hiddenInput = $('<input>').attr({
                type: 'hidden',
                name: 'new_images_priorities' + '[' + event.target.fileName + ']',
                value: '' // counter
            });

            $li.append($($.parseHTML('<img>'))
               .attr({'src': event.target.result, 'data-url': dataUrl}))
               .insertBefore($('.drop-photo'));
            $li.append($button);
            $li.append($hiddenInput.attr('value', getPriority));
            $('.thumbnails .thumbnails-item').first().addClass('thumbnails-item__first');

            if(editReferer === false){
                if($('.thumbnails').children('.thumbnails-item').length > 0){
                    parentPage.find('.btn-info.next').removeClass('hidden');
                    parentPage.find('.btn-skip-central').removeClass('hidden');
                    parentPage.find('.btn-skip-right').addClass('hidden');
                }
            }

            setImagesPriority();
            makeImagesSortable();
        };
        reader.readAsDataURL(inputItem);
    };

    function makeImagesSortable(){
        $('.sortable-container .thumbnails').sortable({
            items: '.thumbnails-item',
            revert: true,
            containment: 'document',
            tolerance: 'pointer',
            update: function(){
                $('.sortable-container .thumbnails-item:not(:first)').each(function(){
                    $(this).removeClass('thumbnails-item__first');
                });

                $('.sortable-container .thumbnails-item').first().addClass('thumbnails-item__first');
            },
            stop: function(){
                setImagesPriority();
                $('.sortable-container .thumbnails-item').each( function( index ) {
                    var dataUrl = $(this).find('img').data('url');
                    var priority = $(this).find('input').val();
                    var newIndex = ++index;
                    $.ajax({
                        method: 'PATCH',
                        url: dataUrl,
                        data: { priority: priority }
                    });
                });
            }
        })
    };

    function setImagesPriority() {
        $('#thumbnails input').each(function (index) {
            $(this).attr({value: index})
        });
    };

    // Multyple upload UPDATE
    $(document).on('change', '#multipleImg', function () {        
        var formData = new FormData(),
            uploadedMessage = $(this).data('uploaded-message'),
            uploadingMessage = $(this).data('uploading-message'),
            
            apiBoatImageUrl = $('#multipleImg').data('url'),
            workInput = $(this),
            workInputObj = this,
            $files = workInputObj.files;

        for (var i = 0; i < $files.length; ++i) {
            formData.append('file', $files[i]);
            formData.append('priority', $('.thumbnails-item').length);

            var inputItem = $files[i];
            var messageText = ""

            $.ajax({
                type: 'POST',
                url: apiBoatImageUrl,
                contentType: false, // Not set any content type header.
                processData: false, // Prevent automatic conversion of data to strings.
                data: formData,
                async: false, //may be refactored
                beforeSend: function ( xhr ) {    
                    addFlashMessage(uploadingMessage);
                },                
                success: function (imageObject) {
                    var dataUrl = apiBoatImageUrl + '/' + imageObject.id;
                    getPriority = imageObject.priority;
                    imagesPreview(inputItem, ".thumbnails", dataUrl);
                    messageText = uploadedMessage;
                },
                error: function (jqXHR) {
                    //$('.alert-text').text(jqXHR.responseJSON.message);
                    messageText = jqXHR.responseJSON.message;
                }
            });
        };
        removeFlashMessage();
        displayFlashMessage(messageText);
    });

    $('.thumbnails').on('click', '.remove-btn', function () {
        var parent = $(this).parents('.thumbnails-item');
        var parentPage = $(this).parents('.wizard-page');
        // var confirmationMessage = $(this).parents('#thumbnails').data('confirmation-message');
        var isDeletionConfirmed = true; // confirm(confirmationMessage);
        var deletedMessage = $('#multipleImg').data('deleted-message');

        if (isDeletionConfirmed) {
            $.ajax({
                type: 'DELETE',
                dataType: 'json',
                data: {},
                url: $(this).data('url'),
                success: function () {
                    parent.remove();
                    $('.thumbnails .thumbnails-item').first().addClass('thumbnails-item__first');
                    if(editReferer === false) {
                        if ($('.thumbnails').children('.thumbnails-item').length === 0) {
                            parentPage.addClass("testeeeeer");
                            parentPage.find('.btn-info.next').addClass('hidden');
                            parentPage.find('.btn-skip-central').addClass('hidden');
                            parentPage.find('.btn-skip-right').removeClass('hidden');
                        }
                    }
                    if ($('div.alert').length == 0) {
                        displayFlashMessage(deletedMessage);
                    }
                    setImagesPriority();
                },
                error: function (error) {
                    console.log(error);
                }
            });
        }
    });

    // // Draggable thumb images
    // dragula([document.getElementById('thumbnails')], { revertOnSpill: true })
    //   .on('drop', function () {
    //     setImagesPriority();
    //   });

    // Code to solve the calculation of meters and feet RFS

    var wmeters= [];
    var wfeets= [];
    var wcm= 0;
    var wcf= 0;

    $("#boat_length").on("keyup", function(){
        $("#length_ft").val(convft($(this).val()));
        wmvalue = $(this).val();
        wmeters [wcm] =  Number.parseFloat(wmvalue).toFixed(2);
        wcm += 1;
    });

    $("#boat_length").on("focusout", function(){
       if (wcm >0){
         $(this).val(wmeters[(wcm-1)]);
         wmeters.length = 0;
         wcm = 0;
       }
    });
    $("#length_ft").on("keyup", function(){
        $("#boat_length").val(convmt($(this).val()));
        wfvalue =  $(this).val();
        wfeets [wcf] =  Number.parseFloat(wfvalue).toFixed(2);
        wcf += 1;

    });
    $("#length_ft").on("focus", function(){
        if ($("#boat_length").val() > 0.00){
          $(this).val(convft($("#boat_length").val()));
        }
    });
    $("#length_ft").on("focusout", function(){
        if (wcf > 0){
          $(this).val(wfeets[(wcf-1)]);
          wfeets.length = 0;
          wcf = 0;
        }
    });
    function convft(x) {
      cft= x / 0.3048
      return Number.parseFloat(cft).toFixed(2);
    }
    function convmt(x) {
      cmt= x * 0.3048
      return Number.parseFloat(cmt).toFixed(2);
    }
 
    // End code 

    $("#boat_season_rates_attributes_0_minimum_stay").on("change", function(){
        updateMinStayInputs();
    });

});
