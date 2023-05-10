//= require ../application
//= require jquery.rateyo.min

$(document).ready(function(){
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
            readOnly: $field.prop( "disabled"),
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
            $("#review_recommended").val(true);
        }
    });
    $(".rec-frown").on("click", function(e){
        e.preventDefault();
        if(!$(this).hasClass("active")) {
            $(this).addClass("active");
            $(".rec-smile").removeClass("active");
            $("#review_recommended").val(false);
        }
    });
    
    // Init
    var isRecommend = $("#review_recommended").val();
    if(isRecommend) {
        $(".rec-smile").addClass("active");
    } else {
        $(".rec-frown").addClass("active");
    };

    $(".btn-send-review").on("click", function(e){
        e.preventDefault();
        var $text = $("#review_public_review");
        if($text.val()) {
            $(this).parents('form').submit();
        } else {
            $text.addClass('input-error');
            $text.parent().append('<span class="field-error">Please enter public feedback</span>');
            $(window).scrollTop(0);
        }
    })
});

