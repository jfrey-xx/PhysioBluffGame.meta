#!/bin/sh

# will video processing on LSL streams
# Note: all soft will be killed upon exit.
# TODO: should really use a list...

# use konsole to show output of our nice programs
BINARY="xterm -hold -e"

# soft that'll be launched and its folder
TARGET_FOLDER="~/bluff_game/pseye_unleashed/convert_raw/"
TARGET_COM="./pseye2loopback --width 640 --height 480"

# waiting time between launch (s)
SLEEPY=4

# parameters for each instance
PARAMS_1="--video-in /dev/video1 --video-out /dev/video4"
DESKTOP_1="2"

PARAMS_2="--video-in /dev/video2 --video-out /dev/video5"
DESKTOP_2="3"

PARAMS_3="--video-in /dev/video3 --video-out /dev/video6"
DESKTOP_3="4"

# remember current desktop to go back here after
# FIXME: may not work with a *vast* amount of desktop
CURRENT_DESKTOP=`wmctrl -d | grep "*" | head -c 1`
echo "Current desktop: $CURRENT_DESKTOP"

echo "Lauching soft 1 in desktop $DESKTOP_1"
wmctrl -s $DESKTOP_1
$BINARY "cd $TARGET_FOLDER && $TARGET_COM $PARAMS_1" > /dev/null 2>&1 &
sleep $SLEEPY

# dead code, not used in fact, but maybe in the future...
# could not use $! since child spawn another process
# FIXME: a bit tricky, may spot the wrong condidate, even if we only retain the last one launched
#PID_1=`pgrep -f "openvibe.*$SCENAR_PATH/$OV_SCENAR_1.*" | tail -1`
#echo "Got PID $PID_1"

echo "Lauching soft 2 in desktop $DESKTOP_2"
wmctrl -s $DESKTOP_2
$BINARY "cd $TARGET_FOLDER && $TARGET_COM $PARAMS_2" > /dev/null 2>&1 &
sleep $SLEEPY

echo "Lauching soft 3 in desktop $DESKTOP_3"
wmctrl -s $DESKTOP_3
$BINARY "cd $TARGET_FOLDER && $TARGET_COM $PARAMS_3" > /dev/null 2>&1 &
sleep $SLEEPY

echo "Go back to desktop $CURRENT_DESKTOP"
wmctrl -s $CURRENT_DESKTOP

# An infinite loop that will take all child processes with it if breaks
while :
do
  read -p "^C to quit and kill everyONE> " USER_KEY
done
