//= require ../application

$(document).ready(function() {
  if($('#current-user-id').length != 0) {
    var idUser = $('#current-user-id').val();
  };
  $('.wish-delete').on('click', function(e){
    e.preventDefault();
    var idList = $(this).data('id');
    $.ajax({
      type: 'DELETE',
      url: '/api/users/' + idUser + '/wishlist/' + idList + '.json',
      success: function(data) {
        console.log('all goods');
      },
      error: function (error) {
        console.log(error);
      },
    });
    $(this).parents('.wishlist-item').detach();
    //print deleting message
    displayFlashMessage($('#title-delete-wishlist').val());
  });
});
