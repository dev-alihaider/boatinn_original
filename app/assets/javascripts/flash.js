function slowFlashHide() {
  setTimeout(function(){
    $('#flash_messages .alert').fadeOut();
  }, 5000);
  setTimeout(function(){
    $('#flash_messages .alert').detach();
  }, 7000);
};

function displayFlashMessage(message) {
  $("#flash_messages").prepend('<div class="alert alert-alert"><div class="alert-text">'
    + message
    + '</div><button class="alert-close button btn-negative">Close</button></div>');
  slowFlashHide();
};

function addFlashMessage(message) {
  $("#flash_messages").prepend('<div class="alert alert-alert"><div class="alert-text">'
    + message
    + '</div><button class="alert-close button btn-negative">Close</button></div>');
};

function removeFlashMessage() {
  $('#flash_messages .alert').detach();
};

$(document).on('click', '.alert-close', function(e){
  e.preventDefault();
  $('#flash_messages .alert').fadeOut();
  setTimeout(function(){
    $('#flash_messages .alert').detach();
  }, 2000);
});

$(document).ready(function() {
  slowFlashHide();
});
