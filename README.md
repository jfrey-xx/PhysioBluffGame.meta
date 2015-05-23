 
# "Bluff Game" experiment

Links to needed repositories, scripts for final XP.

Suppose that this repo is cloned as ~/bluff_game folder (otherwise change tools/* accordingly).

# Requirements:

* openvibe 1.0.0
* wmctrl and xterm (automation of programs)

* Processing libraries
    * lsllink 0.1
    * used papart's archive "libs.tgz", 28-Apr-2015 18:27, 151M
    * papart snapshot: PapARt-15-05-07-20-18.tg, 07-May-2015 20:18, 18M

# How to

## Setup XP conditions

- HR & ambient feedack, to be set in PhysioBluffGame/BluffTable/config.pde

## Init webcam

Plug in the right order PSEye ID 0,1,2 -- they will get video1,2,3 as video0 is tracking webcam.

Load modules, set parameters for V4L2Loopback and PSEye: tools/init_webcams.sh (tune GAIN variable according to ambient luminosity)

## Launch video pipeline

PSEye acquisition: tools/launch_pseye2loopback.sh

Set white balance for each cam with misc/PDI_Target_ProPhotoRGB.jpg

Video acquisition: tools/launch_video_acquisition.sh

Signal processing: tools/launch_video_processing.sh

## Launch recorder

tools/launch_labrecorder.sh
tools/launch_ovrecorder.sh

## Launch Processing for feedbacks

Sketch in PhysioBluffGame/BluffTable/

For first time, calibrate using procamcalib, set targets.

After sketch launch: tools/bluff_table_first.sh
