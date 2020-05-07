#!/bin/bash

certbot renew
service nginx reload
