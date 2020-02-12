var hostname = document.location.hostname.split('.');
var domain;
var path = ";path=/";
if (hostname.length > 2) {
    domain = '.' + hostname.slice(1, hostname.length).join('.');
} else {
    domain = '.' + document.location.hostname;
}
domain = ";domain=" + domain;


function get_cookie(cookie_name) {
    if (document.cookie.length > 0) {
        start = document.cookie.indexOf(cookie_name + "=");
        if (start < 0) return null;
        end = document.cookie.indexOf(";", start);
        if (end == -1) { end = document.cookie.length; }
        return unescape(document.cookie.substring(start, end));
    }
    return null;
}

function has_consent() {
    return navigator.doNotTrack != '1' && get_cookie('hasConsent') == 'hasConsent=true';
}

function purge_cookie(cookie_name) {
    var expiration = "Thu, 01-Jan-1970 00:00:01 GMT";
    document.cookie = cookie_name + "=" + path + ";expires=" + expiration;
}

function purge_ga_cookies() {
    var names = ["__utma","__utmb","__utmc","__utmz", "__utmt", "_ga", "_gat"]
    for (var i = 0; i < names.length; i++) {
        purge_cookie(names[i]);
    }
}

function get_expiration() {
    var date = new Date();
    date.setMonth(date.getMonth() + 1);
    var expires = ";expires="+date.toGMTString();
    return expires;
}

function close_banner() {
    var div = document.getElementById('consent_banner');
    div.style.display = 'none';
}

function ga_refuse() {
    document.cookie = 'hasConsent=false'+ get_expiration() + path + domain;
    var banner = document.getElementById('consent_banner');
    banner.innerHTML='Vous vous êtes opposé au dépôt de cookies de mesures \
d\'audience dans votre navigateur.';
    window.setTimeout(function() { banner.style.display = 'none'; return true; }, 5000);
    purge_ga_cookies();
}

function consent_banner() {
    var body = document.getElementsByTagName('body')[0];
    var banner = document.createElement('div');
    var content = '<button type="button" onclick="javascript:close_banner()" title="Utiliser ce bouton signifie acceptation du suivi">×</button>';
    content += 'En poursuivant votre navigation sur ce site, vous acceptez l\'utilisation de cookies à des fins de mesure d\'audience.';
    content += '<div class="actions"><span class="accept"><a href="javascript:close_banner()">Accepter le suivi</a></span> / <span class="refuse"><a href="javascript:ga_refuse()">M\'opposer au suivi</a></span></div>';
    banner.setAttribute('id', 'consent_banner');
    banner.innerHTML = content;
    body.insertBefore(banner, body.firstChild);
    /* no action is accepting */
    document.cookie = 'hasConsent=true'+ get_expiration() + path + domain;
}

if (navigator.doNotTrack != '1') {
    var consent_cookie = get_cookie('hasConsent');

    if (!consent_cookie) {
        window.onload = consent_banner;
    } else {
        if (!has_consent()) {purge_ga_cookies();}
    }
}
