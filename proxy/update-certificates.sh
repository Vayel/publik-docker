#!/bin/bash

certbot renew -w /home/http
service nginx reload
