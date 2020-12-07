#!/bin/bash

SUCCESS='\033[0;32m'
WARNING='\033[0;33m'
ERROR='\033[0;31m'
INFO='\033[0;34m'
NC='\033[0m' # No Color

function echo_warning() {
  echo -e "${WARNING}$1${NC}"
}

function echo_error() {
  echo -e "${ERROR}$1${NC}"
}

function echo_success() {
  echo -e "${SUCCESS}$1${NC}"
}

function echo_info () {
  echo -e "${INFO}$1${NC}"
}
