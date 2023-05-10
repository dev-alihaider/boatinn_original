//= require ../application
$("a[href='#print']").click(function(e){
    e.preventDefault();
    window.print();
});
