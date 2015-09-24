#!/bin/sh

# will video processing on LSL streams
# Note: all soft will be killed upon exit.
# TODO: should really use a list...

# use konsole to show output of our nice programs
BINARY="xterm -hold -e"

# soft that'll be launched and its folder
TARGET_FOLDER="~/bluff_game/pseye_unleashed/convert_raw/"
TARGET_COM="./pseye2loopback --width 640 --height 480"


# parameters for each instance
PARAMS_1="--video-in /dev/video1 --video-out /dev/video2"


echo "Current desktop: $CURRENT_DESKTOP"
echo "Lauching soft 1"
$BINARY "cd $TARGET_FOLDER && $TARGET_COM $PARAMS_1" > /dev/null 2>&1 &


# An infinite loop that will take all child processes with it if breaks
while :
do
  read -p "^C to quit and kill everyONE> " USER_KEY
done
