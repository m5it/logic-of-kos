#!/bin/bash
#
sudo pacman -Syu --needed base-devel git
#
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
#
yay --version
