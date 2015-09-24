#!/bin/sh

# will video processing on LSL streams
# Note: all soft will be killed upon exit.
# TODO: should really use a list...

# use konsole to show output of our nice programs
BINARY="xterm -hold -e"

# soft that'll be launched and its folder
TARGET_FOLDER="~/bluff_game/pdp_kinect/process/"
TARGET_COM="python main.py"



# parameters for each instance
PARAMS_1="--algo 1 --user-id 0"



echo "Lauching soft 1"

$BINARY "cd $TARGET_FOLDER && $TARGET_COM $PARAMS_1" > /dev/null 2>&1 &


# An infinite loop that will take all child processes with it if breaks
while :
do
  read -p "^C to quit and kill everyONE> " USER_KEY
done
