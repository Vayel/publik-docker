GADJO_DEFAULT_SIDEPAGE_STATUS = 'expanded';

$(function() {
  var all_done = false;

  if (PUBLIK_ENVIRONMENT_LABEL) {
    $('body').attr('data-environment-label', PUBLIK_ENVIRONMENT_LABEL);
  }

  if (PUBLIK_PORTAL_AGENT_EXTRA_CSS) {
    $('<link rel="stylesheet" type="text/css" media="all" href="' +
                    PUBLIK_PORTAL_AGENT_EXTRA_CSS + '"/>').appendTo('head');
  }

  function update_publik_menu() {
    window.sessionStorage.hobo_environment = JSON.stringify(COMBO_KNOWN_SERVICES);
    window.sessionStorage.hobo_environment_timestamp = Date.now();
    create_menu_items();
    $(document).trigger('publik:environment-loaded', {services: COMBO_KNOWN_SERVICES});
  }

  function create_menu_items() {
    $('#sidepage-menu').remove();
    var menu_links = $('<ul id="sidepage-menu">');
    if (PUBLIK_PORTAL_AGENT_URL && PUBLIK_PORTAL_AGENT_TITLE) {
      var li = $('<li id="portal-agent-home"><a>' + PUBLIK_PORTAL_AGENT_TITLE + '</a></li>').appendTo(menu_links);
      $(li).find('a').attr('href', PUBLIK_PORTAL_AGENT_URL).addClass('icon-home');
      $(li).find('a').attr('href', PUBLIK_PORTAL_AGENT_URL).prop('title', PUBLIK_PORTAL_AGENT_TITLE);
    }
    var more_entries = Array();
    var service_order = Array('authentic', 'welco', 'wcs', 'bijoe', 'chrono', 'corbo', 'combo', 'passerelle', 'hobo');
    COMBO_KNOWN_SERVICES.sort(function(a, b) {
      a_service_order = service_order.indexOf(a.service_id);
      b_service_order = service_order.indexOf(b.service_id);
      if (a_service_order == b_service_order) {
         return a.service_id.localeCompare(b.service_id);
      }
      if (a_service_order < 0) return 1;
      if (b_service_order < 0) return -1;
      return a_service_order - b_service_order;
    });
    $(COMBO_KNOWN_SERVICES).each(function(index, service) {
      if (service.data === undefined || service.data.length == 0) {
         return;
      }
      $(service.data).each(function(idx, element) {
        var li = $('<li><a href="#">' + element.label + '</a></li>').appendTo(menu_links);
        $(li).find('a').attr('href', element.url);
        $(li).find('a').attr('title', element.label);
        if (element.icon !== undefined) {
          $(li).find('a').addClass('icon-' + element.icon);
        } else if (element.slug !== undefined) {
          $(li).find('a').addClass('icon-' + element.slug);
        }
        if (element.sub === true) {
          $(li).addClass('sub');
        }
        if (window.location.href.indexOf(element.url) == 0) {
          $(li).addClass('active');
        }
      });
    });
    $(more_entries).each(function(index, entry) {
      var li = $('<li><a href="#">' + entry.title + '</a></li>').appendTo(menu_links);
      $(li).find('a').attr('href', entry.url);
    });
    menu_links.appendTo('#sidepage');
    $(document).trigger('publik:menu-loaded');
  }

  if (window.sessionStorage.hobo_environment &&
      parseInt(window.sessionStorage.hobo_environment_timestamp) > Date.now()-600000) {
    COMBO_KNOWN_SERVICES = JSON.parse(window.sessionStorage.hobo_environment);
    $(document).trigger('publik:environment-loaded', {services: COMBO_KNOWN_SERVICES});
    create_menu_items();
  } else {
    var this_hostname = window.location.hostname;
    var look_for_wcs = false;
    var got_wcs = false;
    var authentic_url = undefined;

    $(COMBO_KNOWN_SERVICES).each(function(index, element) {
      if (element.backoffice_menu_url === null) {
        element.data = Array();
        update_publik_menu();
        return;
      }
      if (element.service_id === 'wcs' && element.uniq === false) {
        /* as wcs comes with many menu entries, if it's not the only instance
         * in the environment, we simply skip it if it's not the active site.
         */
        var that_hostname = $('<a>').attr('href', element.backoffice_menu_url)[0].hostname;
        if (that_hostname != this_hostname) {
          look_for_wcs = true;
          element.data = Array();
          update_publik_menu();
          return;
        } else {
          got_wcs = true;
        }
      }

      if (element.service_id === 'authentic') {
        authentic_url = element.url;
      }

      $.ajax({url: element.backoffice_menu_url,
            xhrFields: { withCredentials: true },
            async: true,
            dataType: 'jsonp',
            crossDomain: true,
            success: function(data) { element.data = data; update_publik_menu(); },
            error: function(error) { window.console && console.log('bouh', error); element.data = Array(); update_publik_menu(); }
           }
       );
    });
    if (! got_wcs && look_for_wcs && authentic_url) {
      /* if there is several wcs instances, we ask authentic for details on the
       * user, to get the services where the user has some roles
       */
      $.ajax({url: authentic_url + 'api/user/',
              xhrFields: { withCredentials: true },
              async: true,
              dataType: 'jsonp',
              crossDomain: true,
              success: function(data) {
                var services_to_consider = Array();
                /* iterate over all services, to get those to consider */
                $(COMBO_KNOWN_SERVICES).each(function(index, element) {
                  if (element.service_id !== 'wcs') return;
                  $(data.services).each(function(auth_index, auth_element) {
                    if (auth_element.slug !== element.slug) return;
                    if (auth_element.roles.length == 0) return;
                    element.preferred = (data.ou__uuid == auth_element.ou__uuid);
                    services_to_consider.push(element);
                  });
                });
                if (services_to_consider.length > 1) {
                  /* if there are multiple wcs, reduce the list to those from
                   * the same organizational unit as the user
                   */
                  services_to_consider = services_to_consider.filter(
                    function(element) { return element.preferred == true; }
                  );
                }
                if (services_to_consider.length == 1) {
                  /* only handle the case with a single service, for now */
                  var element = services_to_consider[0];
                  $.ajax({url: element.backoffice_menu_url,
                        xhrFields: { withCredentials: true },
                        async: true,
                        dataType: 'jsonp',
                        crossDomain: true,
                        success: function(data) { element.data = data; update_publik_menu(); },
                        error: function(error) {
                                window.console && console.log('bouh', error);
                                element.data = Array(); update_publik_menu();
                        }
                  });
                }
              },
              error: function(error) { window.console && console.log('bouh', error); }
             }
      );
    }
  }

  var sidepage_button = $('#sidepage #applabel');
  sidepage_button.css('visibility', 'visible');

  /* This won't work if portal agent is installed directly in a top domain
   * name. Live with it. */
  var cookie_domain = window.location.hostname.split('.').slice(1).join('.');
  var date = new Date();
  date.setTime(date.getTime() + (10 * 86400 * 1000)); /* a long week */
  document.cookie = 'publik_portal_agent_url=' +
          encodeURIComponent(PUBLIK_PORTAL_AGENT_URL) +
          '; expires=' + date.toGMTString() +
          '; domain=.' + cookie_domain + '; path=/';
  document.cookie = 'publik_portal_agent_title=' +
          encodeURIComponent(PUBLIK_PORTAL_AGENT_TITLE) +
          '; expires=' + date.toGMTString() +
          '; domain=.' + cookie_domain + '; path=/';
});
