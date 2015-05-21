#!/bin/sh

# put bluff table sketch on all desktops...
wmctrl -F -r "BluffTable" -t -2
# and above all other windows
wmctrl -F -r "BluffTable" -b add,above
