//= require ../application
$(document).ready(function(){
    var form = $("form[data-api-path]");
    var api_path = form.data('api-path');
    var month_container = $(".total-for-month");
    var year_container  = $(".total-for-year");

    form.find("select").change(function(){
        var data = form.serialize();
        $.get(api_path, data, function(earns){
            month_container.find('tr').hide();
            $.each(earns.for_month, function(key, value){
                month_container.find('tr.' + key).show().find('strong').text(value);
            });

            year_container.find('tr').hide();
            $.each(earns.for_year, function(key, value){
                year_container.find('tr.' + key).show().find('strong').text(value);
            });
        }, 'json')
    });/* end change */
});/* end ready */
