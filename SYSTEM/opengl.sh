#!/bin/bash
#
#
#--






echo "Rendering: "
glxinfo | grep rendering

echo "OpenGL: "
glxinfo | grep OpenGL

echo "lspci: "
lspci | grep -i VGA

# lshw, lscpu, rocm-smi
