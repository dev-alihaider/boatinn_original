//= require application

$(document).ready(function () {
  function setNumberPosition() {
    var chart = $('.chart-item');
    var chartItem = chart.find('.chart-item-inner');

    chartItem.each(function (index, el) {
      var chartHeight = $(el).height();
      var chartNumber = $(el).parent().find('.number');
      var position = chartHeight + 3;

      chartNumber.css('bottom', position);
    });
  }

  setNumberPosition();

  function circleChartPercentage() {
    var parent = $('.single-chart');
    var percentage;

    parent.each(function (index, el) {
      var value = $(el).data('val');
      var maxValue = $(el).data('max');

      var item = $(el).find('.circular-chart');
      var itemInner = item.find('.circle');

      percentage = value * 100 / maxValue;
      itemInner.attr({'stroke-dasharray': percentage + ', 100'});
    });
  }

  circleChartPercentage();

  // Listing navigation.
  $('#switch_listing').on('select2:select', function () {
    $(location).attr('href', $(this).find('option:selected').data('path'));
  });
});
