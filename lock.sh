#!/bin/bash

scrot -e 'convert $f -blur 0x10 $f && i3lock -i $f && rm $f'

# Turn off the screen
sleep 60;
pgrep i3lock && xset dpms force off
