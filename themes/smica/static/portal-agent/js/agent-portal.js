$(function() {
  $(document).on('publik:environment-loaded', function(event, services) {
    /* empty all apps cells */
    var service_ids = Array('authentic', 'wcs', 'combo', 'passerelle', 'hobo');
    $(service_ids).each(function(index, service_id) {
      $('#portal-agent-content div.services-' + service_id + ' ul.apps').empty();
    });
    $('#portal-agent-content div.services ul.apps').empty();
    /* and fill them with current services */
    $(services.services).each(function(index, element) {
      var $content = $('#portal-agent-content div.services-' + element.service_id);
      if ($content.length === 0) {
        $content = $('#portal-agent-content div.services');
      }
      if ($content.find('ul.apps').length === 0) {
        $('<ul class="apps">').appendTo($content);
      }
      var $apps = $content.find('ul.apps');
      $(element.data).each(function(index, menuitem) {
        var li = $('<li><a href="' + menuitem.url + '">' + menuitem.label + '</a></li>').appendTo($apps);
        if (menuitem.icon !== undefined) {
          $(li).addClass('icon-' + menuitem.icon);
        } else if (menuitem.slug !== undefined) {
          $(li).addClass('icon-' + menuitem.slug);
        }
      });
    });
  });
  $(document).on('publik:menu-loaded', function(event, services) {
    /* mark our location in publik menu */
    $('#portal-agent-home').addClass('active');
  });
  $('div.searchcell').delegate('li.see-more a', 'click', function() {
    $(this).parents('.combo-search-results').toggleClass('expanded');
    return false;
  });
});
