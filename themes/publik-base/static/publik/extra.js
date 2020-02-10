$(function() {
  $('div.wcsformsofcategorycell').delegate('h2', 'click', function() {
    $(this).parents('div.wcsformsofcategorycell').toggleClass('toggled');
  });
});
