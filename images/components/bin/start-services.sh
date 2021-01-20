#!/bin/bash

function check_services {
  for S in memcached combo passerelle chrono fargo hobo supervisor authentic2-multitenant wcs nginx
  do
    # We use the "or" to avoid exiting the script if the status returns a non-zero
    # code
    ret_code=0
    service $S status || ret_code=$?

    if [ "$ret_code" != '0' ]; then
      service $S stop
      sleep 2
      service $S start
    fi
  done
}

service memcached start
service combo start
service passerelle start
service fargo start
service chrono start
service hobo start
service supervisor start
service authentic2-multitenant start
service wcs start
service nginx start

sleep 2

check_services
