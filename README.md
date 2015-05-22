 
Links to needed repositories, scripts for final XP.

Requirements:

* openvibe 1.0.0
* wmctrl (automation of programs)

Suppose that this repo is cloned as ~/bluff_game folder (otherwise change tools/* accordingly).

# How to

## setup XP conditions

- HR & ambient feedack

## programs

Video acquisition: tools/launch_video_acquisition.sh

Signal processing: tools/launch_video_processing.sh

After sketch launch:

tools/bluff_table_first.sh

# by hand

## pseye_unleashed

Plug in the right order ps eye ID 0,1,2 -- they will get video1,2,3 as video0 is tracking webcam

load modules

sudo modprobe v4l2loopback video_nr=4,5,6 card_label="ps eye raw 0","ps eye raw 1","ps eye raw 2" 

v4l2-ctl -d /dev/video4 --set-ctrl  sustain_framerate=1
sudo v4l2loopback-ctl set-fps 30 /dev/video10

v4l2-ctl -d /dev/video5 --set-ctrl  sustain_framerate=1
sudo v4l2loopback-ctl set-fps 30 /dev/video11

v4l2-ctl -d /dev/video6 --set-ctrl  sustain_framerate=1
sudo v4l2loopback-ctl set-fps 30 /dev/video12

## PSeye

Enable raw mode and set frame rate for ps eye:

setup exposure / focus mode / flip / light param

(0 is webcam for tracking)

focus_automatic_continuous=1 : bayer
set-parm=30 : FPS
horizontal_flip=1 and vertical_flip=1 : camera is upside down
auto_exposure=1 and exposure=255 : against noise (if sufficient light for framerate)
gain_automatic=0 and gain=?? : set accordingly to light condition

export GAIN=16

v4l2-ctl -d /dev/video1 --set-parm=30 \
  --set-ctrl focus_automatic_continuous=1 \
  --set-ctrl horizontal_flip=1 \
  --set-ctrl vertical_flip=1 \
  --set-ctrl auto_exposure=1 \
  --set-ctrl exposure=255 \
  --set-ctrl gain_automatic=0 \
  --set-ctrl gain=$GAIN

v4l2-ctl -d /dev/video2 --set-parm=30 \
  --set-ctrl focus_automatic_continuous=1 \
  --set-ctrl horizontal_flip=1 \
  --set-ctrl vertical_flip=1 \
  --set-ctrl auto_exposure=1 \
  --set-ctrl exposure=255 \
  --set-ctrl gain_automatic=0 \
  --set-ctrl gain=$GAIN

v4l2-ctl -d /dev/video3 --set-parm=30 \
--set-ctrl focus_automatic_continuous=1 \
--set-ctrl horizontal_flip=1 \
--set-ctrl vertical_flip=1 \
--set-ctrl auto_exposure=1 \
--set-ctrl exposure=255 \
--set-ctrl gain_automatic=0 \
--set-ctrl gain=$GAIN

NB: could also try v4l2ctrl -l config_file -d /dev/video1

## Launch pseye2loopback
 
pseye_unleashed/convert_raw
 
./pseye2loopback --width 640 --height 480 --video-in /dev/video1 --video-out /dev/video4

./pseye2loopback --width 640 --height 480 --video-in /dev/video2 --video-out /dev/video5

./pseye2loopback --width 640 --height 480 --video-in /dev/video3 --video-out /dev/video6

set white balance for each (sheet, press space bar)

## launch video acquisition

pdp_kinect/src

(algo 1 == luv)

python main.py --webcam 4 --user-id 0 --algo 1

python main.py --webcam 5 --user-id 1 --algo 1

python main.py --webcam 6 --user-id 2 --algo 1

## launch video processing

pdp_kinect/process

python main.py --algo 1 --user-id 0

python main.py --algo 1 --user-id 1

python main.py --algo 1 --user-id 2

## launch recorder

tools/launch_labrecorder.sh
tools/launch_ovrecorder.sh

## launch Processing and feedback

￼	libs.tgz	28-Apr-2015 18:27	151M

lsllink 0.1

PapARt-15-05-07-20-18.tgz	07-May-2015 20:18	18M	


(calibration, setting targets)

set correct condition