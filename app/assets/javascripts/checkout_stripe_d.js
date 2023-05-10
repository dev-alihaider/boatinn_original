$(document).ready(function(){
    var elements = stripe.elements();

    var cardNumber = elements.create('cardNumber');
    cardNumber.mount('#card_number');

    var cardExpiry = elements.create('cardExpiry');
    cardExpiry.mount('#c_month');

    var cardCvc = elements.create('cardCvc');
    cardCvc.mount('#security_code');

    var postalCode = elements.create('postalCode');
    postalCode.mount('#postalCode');

    window.stripeCardNumber = cardNumber
});

function add_credit_card(callback) {
    stripe.createToken(window.stripeCardNumber).then(function(result) {
        if (result.error) {
            var errorElement = document.getElementById('card-errors');
            errorElement.textContent = result.error.message;
            callback(false);
        } else {
            path = $("#add-credit-card").data('path');
            data = { stripe_card_token: result.token['id'] };
            data.card_details = {
                address_country: $("#card_details_address_country").val(),
                name: $("#card_details_name").val()
            };

            result = $.ajax({
                type: 'POST',
                url: path,
                data: data,
                async: false,
                cache: false
            });
            if (result.status == 200) {
                $('#stripe_card_token').remove();
                callback(true);
            }
        }
    });
}
