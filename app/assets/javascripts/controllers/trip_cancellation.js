//= require application

$(document).ready(function(){
  $("#btn_cancel").click(function(e){
    e.preventDefault();
    $(this).addClass("btn-disabled");
    var form = $("#new_trip_cancellation");
    var path = form.attr('action');
    var data = form.serializeArray();
    $.post(path, data, function(response){
        if (typeof response == 'object' && response.redirect_to) {
            window.location = response.redirect_to;
        } else {
           $("#cancellation-update-container").html(response);
        }
    });
  });
});
