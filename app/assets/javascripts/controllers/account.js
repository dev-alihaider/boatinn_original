//= require application

$(document).ready(function() {

  $('.select-default-card').on('change', function(){
      var url = $(this).data('url'),
          id = $(this).data('id');
      $.ajax({
          type: 'PATCH',
          url: url,
          data: {id: id},
          success: function(){
          },
          error: function (error) {
              alert(error);
          }
      });
  });

  //Cancel Switcher
  $('.btn-cancel-account').on('click', function(e){
    e.preventDefault();
    $(this).parents('.content').addClass('active');
    $(this).hide();
  });
  $('.btn-dont-cancel-account').on('click', function(e){
    e.preventDefault();
    $(this).parents('.content').removeClass('active');
    $('.btn-cancel-account').show();
  });

  // var isFirefox = typeof InstallTrigger !== 'undefined';

  // if(isFirefox === true) {
  //   $('.account-container').find('.inner-content').addClass('firefox');
  // } else {
  //   $('.account-container').find('.inner-content').removeClass('firefox');

  // }

});
