$(function() {
  /* add a link to portal agent if it was visited before */
  function readCookie(name) { /* http://www.quirksmode.org/js/cookies.html */
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for(var i=0;i < ca.length;i++) {
      var c = ca[i];
      while (c.charAt(0)==' ') c = c.substring(1,c.length);
      if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    }
    return null;
  }
  var portal_agent_url = decodeURIComponent(readCookie('publik_portal_agent_url') || '');
  var portal_agent_title = decodeURIComponent(readCookie('publik_portal_agent_title') || '');
  if (portal_agent_url && portal_agent_title) {
    if (PUBLIK_PORTAL_AGENT_TITLE) portal_agent_title = PUBLIK_PORTAL_AGENT_TITLE;
    if (PUBLIK_PORTAL_AGENT_URL) portal_agent_url = PUBLIK_PORTAL_AGENT_URL;
    $('<a id="publik-portal-agent" href="' + portal_agent_url + '">' +
                    portal_agent_title + '</a>').appendTo('body');
  }
});
