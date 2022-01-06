#!/bin/sh

# Change keyboard layout to "US" if it is not
layout=$(xkb-switch -p)
if [ ! "$layout" == "" ]; then
    xkb-switch -s us
fi

# Show rofi
rofi -show drun -show-icons

# Restore previous keyboard layout
if [ ! "$layout" == "" ]; then
    xkb-switch -s "$layout"
fi
