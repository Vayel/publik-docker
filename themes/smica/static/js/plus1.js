$(function() {
  function user_is_authenticated() {
    return $('body').is('.authenticated-user');
  }
  var nearby_list = $('ul.nearby-forms');
  if (nearby_list.length) {
    $(document).on('wcs:maps-ready', function() {
      var $map_widget = $('.qommon-map');
      var map = $map_widget[0].leaflet_map;
      var geojson_data = [];
      nearby_list.find('li[data-id]').each(function(idx, elem) {
        var feature = {
          type: 'Feature',
          properties: {
            id: $(elem).data('id'),
            counter: $(elem).find('.nearby-form--marker-counter').text()
          },
          geometry: {
            type: 'Point',
            coordinates: [$(elem).data('geoloc-lon'), $(elem).data('geoloc-lat')]
          }
        };
        geojson_data.push(feature);
      });

      $(map).on('zoomend moveend', function() {
        /* filter display of nearby items to match the displayed map area */
        nearby_list.find('li').hide();
        map.eachLayer(function(layer){
          if (layer instanceof L.Marker && map.getBounds().contains(layer.getLatLng())) {
            if (layer.feature && layer.feature.properties.id) {
              nearby_list.find('li[data-id="' + layer.feature.properties.id + '"]').show();
              return;
            }
          }
        });
      });

      if (geojson_data) {
        var geo_json = L.geoJson(geojson_data,
          {
            pointToLayer: function (feature, latlng) {
              marker = L.divIcon({
                                  iconAnchor: [0, 0],
                                  popupAnchor: [5, -45],
                                  html: '<a href="#nearby-' + feature.properties.counter + '" class="demand-map-marker">' +
                                         feature.properties.counter + '</a>'
                                 });
              return L.marker(latlng, {icon: marker});
            }
          });
        geo_json.addTo(map);
        $(map).trigger('moveend');
      }
      $('button.nearby-form--plus1').on('click', function() {
        var plus1_url = $(this).data('plus1-url');
        var $dialog = null;
        if (user_is_authenticated()) {
          $dialog = $('<div id="plus1-dialog">'
                      + '<p>Vous allez confirmer le signalement.'
                      + 'Vous pouvez également décider de recevoir un message une fois celui-ci pris en charge.</p>'
                      + '<label><input type="checkbox">Recevoir un message</input></label>'
                      + '</div>');
        } else {
          $dialog = $('<div id="plus1-dialog">'
                      + '<p>Vous allez confirmer le signalement.</p>'
                      + '</div>');
        }
        $dialog.dialog({
          modal: true,
          buttons: [
                    {text: 'Annuler',
                     'class': 'cancel-button',
                     click: function() {
                       $(this).dialog('destroy');
                     }
                    },
                    {text: 'Confirmer',
                     click: function() {
                       var checked = ($(this).find('[type=checkbox]:checked').length > 0);
                       $.ajax({
                         url: plus1_url,
                         data: JSON.stringify({'checked': checked}),
                         type: 'POST',
                         contentType: 'application/json; charset=utf-8',
                         dataType: 'json',
                         success: function(resp) {
                           $dialog.dialog('destroy');
                           $map_widget.parent().find('[type=hidden]').val('0;0');
                           $('div.buttons button[name=submit]').click();
                         }
                       });
                     }
                    }
                   ],
          close: function() {}
        });
        return false;
      });
    });
  }
})
