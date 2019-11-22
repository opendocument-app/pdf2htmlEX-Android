#!/bin/sh
set -eu

# python3-setuptools and python3-wheel are required to pip install meson
sudo apt-get --quiet install --yes python3-setuptools python3-wheel
sudo -H pip3 install meson

# gperf is required by fontconfig
# gettext is required by libfontforge
sudo apt-get --quiet install --yes gperf gettext

