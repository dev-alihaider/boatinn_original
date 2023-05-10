//= require application

$(document).ready(function(){
  $(".request-email-add").on('click', function(e){
    e.preventDefault();
    var count = $('.request-email-field').length + 1;
    var attrs = 'emails[' + --count + ']';
    $('.request-email-field').first().clone().appendTo('#request-emails');
    $('.request-email-field').last().find('input').attr('id', attrs).attr('name', attrs).val('');
  });

  /* dynamic checkout */
  var form      = $("#new_travel_trip");
  var checkout  = $("#dynamic-checkout");
  var api_path  = checkout.data('api-path');

  $("#travel_trip_number_of_guests").on('change', function(){
      /* calculate prices */
      var data = form.serialize();
      $.get(api_path, data, function(prices){
          /* replace quantity in checkout */
          checkout.find(".guest_label").text(prices.guest_label);
          if (prices.rental_type == 'shared') {
              checkout.find(".unit-quantity").text(prices.passenger_quantity);
          } else {

          }
          /* replace subtotal */
          checkout.find(".subtotal").text(prices.subtotal);
          /* replace client fee */
          checkout.find(".client_fee").text(prices.client_fee);
          /* replace total */
          checkout.find(".total").text(prices.total);
          /* replace due first */
          if (prices.will_be_pay_amount) { checkout.find(".will_be_pay_amount").text(prices.will_be_pay_amount); }
          /* replace due next */
          if (prices.will_be_pay_deposit_amount) { checkout.find(".will_be_pay_deposit_amount").text(prices.will_be_pay_deposit_amount); }
      });
  });

}); // end doc ready

