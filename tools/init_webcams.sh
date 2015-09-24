#!/bin/sh

# load modules
sudo modprobe v4l2loopback video_nr=4,11,12,13 card_label="ps eye raw 0","kinect 2 rgb", "kinect 2 ir", "kinect 2 depth" 

# set v4l2loopback to 30fps
v4l2-ctl -d /dev/video4 --set-ctrl  sustain_framerate=1
sudo v4l2loopback-ctl set-fps 30 /dev/video4


# Enable raw mode and set frame rate for ps eye, setup exposure / focus mode / flip / light param
# (0 is webcam for tracking)

# focus_automatic_continuous=1 : bayer
# set-parm=30 : FPS
# horizontal_flip=0 and vertical_flip=0 : force disabling of flip 'cause it bothers how raw image is processed
# auto_exposure=1 and exposure=255 : against noise (if sufficient light for framerate)
# gain_automatic=0 and gain=?? : set accordingly to light condition

# NB: could also try v4l2ctrl -l config_file -d /dev/video1

export GAIN=0

v4l2-ctl -d /dev/video1 --set-parm=30 \
  --set-ctrl focus_automatic_continuous=1 \
  --set-ctrl horizontal_flip=0 \
  --set-ctrl vertical_flip=0 \
  --set-ctrl auto_exposure=1 \
  --set-ctrl exposure=255 \
  --set-ctrl gain_automatic=0 \
  --set-ctrl gain=$GAIN

