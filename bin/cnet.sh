#!/bin/bash

wpa_supplicant -i wlp3s0 -c /etc/wpa_supplicant/wpa_supplicant.conf 2>&1 > /dev/null &
