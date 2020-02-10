$(function() {
  $('.section.foldable.folded h2').append('<span class="disclose-message">(afficher le détail de la demande)</span>');
  $('.section.foldable h2').click(function() {
    $(this).parent('.section').toggleClass('folded');
    $('.qommon-map').trigger('qommon:invalidate');
  });
});
