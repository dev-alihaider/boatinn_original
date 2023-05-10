$(document).ready(function() {
  // Sending report about review.
  $('#send-report-button').on('click', function () {
    var $report_button = $('.report-review-button'),
        review_id = $report_button.data('review-id'),
        reported_message = $report_button.data('reported-message'),
        reason_id = $('input[name="report_reason"]:checked').val();

    $.ajax({
      type: 'POST',
      dataType: 'json',
      data: {
        review_id: review_id,
        reason_id: reason_id
      },
      url: '/api/reports/about_review.json',
      cache: false,
      success: function () {
        displayFlashMessage(reported_message);
      },
      error: function (error) {
        console.log(error);
      }
    });

    $('#report_reason_1').prop('checked', true);
    $('#reportModal').modal('hide');
  });
});
