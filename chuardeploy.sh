#!/bin/bash
#
# Chuarstation deployment file - R. 05-09-17
# Tested in: Raspbian Stretch Lite 2017-09-07 on Raspberry Pi 3 Model B
#
# NOTE: Script to be run as root
#

#
# VARS
#
CH_ROOT="/opt/chuarstation"
CH_LOGFILE="${CH_ROOT}/chuardeploy.log"

#
# FUNCTIONS
#
function ch_deploy_firsttime {
  # First time config if installing in a baseline Raspbian - to be run manually
  sudo -s
  passwd
  systemctl enable ssh
  systemctl restart ssh
  rpi-update
  apt update;apt upgrade -y
  reboot
}

function ch_log {
  echo "$(date "+%D %R") - $1" | tee -a ${CH_LOGFILE}
}

function ch_deploy_sysupdate_raspbian {
  # Dependencies and tools
  ch_log "*** Installing dependency packages from Raspbian repos..."
  apt install -y git vim screen nmap tcpdump cmake fontconfig libasound2-dev &>> ${CH_LOGFILE}
  apt install -y libflac-dev libogg-dev libvorbis-dev libopenal-dev &>> ${CH_LOGFILE}
  apt install -y libjpeg8-dev libfreetype6-dev libudev-dev libraspberrypi-dev &>> ${CH_LOGFILE}
}

function ch_deploy_prepare {  
  # Prepare chuarstation base tree
  ch_log "*** Preparing environment..."
  mkdir ${CH_ROOT} &>> ${CH_LOGFILE}
  mkdir ${CH_ROOT}/bin &>> ${CH_LOGFILE}
  mkdir ${CH_ROOT}/etc &>> ${CH_LOGFILE}
  mkdir ${CH_ROOT}/games &>> ${CH_LOGFILE}
  mkdir ${CH_ROOT}/misc &>> ${CH_LOGFILE}
  mkdir ${CH_ROOT}/src &>> ${CH_LOGFILE}
}

function ch_deploy_sdl2 {
  # SDL 2.0.5
  ch_log "***"
  ch_log "*** Deploying SDL2..."
  ch_log "***"
  mkdir -p ${CH_ROOT}/src/sdl2
  cd ${CH_ROOT}/src/sdl2
  # Get sources
  ch_log "*** SDL2 - Getting sources"
  wget https://www.libsdl.org/release/SDL2-2.0.5.tar.gz
  tar -xzf SDL2-2.0.5.tar.gz
  rm SDL2-2.0.5.tar.gz
  cd SDL2-2.0.5/
  # Prepare cmake environment
  ch_log "*** SDL2 - cmake"
  mkdir build;cd build
  cmake ../ &>> ${CH_LOGFILE}
  # Compile
  ch_log "*** SDL2 - make"
  make -j3 &>> ${CH_LOGFILE}
  # Install system-wide
  ch_log "*** SDL2 - make install"
  make install &>> ${CH_LOGFILE}
  # Link shared libraries
  ch_log "*** SDL2 - ldconfig"
  ldconfig &>> ${CH_LOGFILE}
  cd ../../../..
  ch_log "*** SDL2 deploy finished."
}

function ch_deploy_sfmlpi {
  ch_log "***"
  ch_log "*** Deploying sfml-pi..."
  ch_log "***"
  # Mickelson's SFML-PI
  mkdir src/sfml-pi;cd src/sfml-pi/
  ch_log "*** sfml-pi - Getting sources..."
  wget https://github.com/mickelson/sfml-pi/archive/master.zip
  unzip master.zip > /dev/null
  rm master.zip
  cd sfml-pi-master
  ch_log "*** sfml-pi - cmake"
  mkdir build;cd build
  cmake ../ -DSFML_RPI=1 -DEGL_INCLUDE_DIR=/opt/vc/include -DEGL_LIBRARY=/opt/vc/lib/libEGL.so -DGLES_INCLUDE_DIR=/opt/vc/include -DGLES_LIBRARY=/opt/vc/lib/libGLESv2.so -DGLES2_LIBRARY=/opt/vc/lib/libGLESv2.so  &>> ${CH_LOGFILE}
  ch_log "*** sfml-pi - make"
  make -j4  &>> ${CH_LOGFILE}
  ch_log "*** sfml-pi - make install"
  make install &>> ${CH_LOGFILE}
  ch_log "*** sfml-pi - ldconfig"
  ldconfig &>> ${CH_LOGFILE}
  cd ${CH_ROOT}
  ch_log "*** sfml-pi deploy finished."
}

function ch_deploy_ffmpeg {
  ch_log "***"
  ch_log "*** Deploying FFmpeg..."
  ch_log "***"
  # FFmpeg
  cd src
  mkdir ffmpeg;cd ffmpeg
  ch_log "*** FFmpeg - Getting sources..."
  wget https://github.com/FFmpeg/FFmpeg/archive/master.zip
  unzip master.zip;rm master.zip;cd FFmpeg-master/
  ch_log "*** FFmpeg - ./configure"
  ./configure --enable-mmal --enable-shared &>> ${CH_LOGFILE}
  ch_log "*** FFmpeg - make"
  make -j4 | tee ${CH_LOGFILE}
  ch_log "*** FFmpeg - make install"
  make install &>> ${CH_LOGFILE}
  ch_log "*** FFmpeg - ldconfig"
  ldconfig &>> ${CH_LOGFILE}
  cd ${CH_ROOT}
  ch_log "*** FFmpeg deploy finished."
}
function ch_deploy_attract {
  ch_log "***"
  ch_log "*** Deploying Attract-Mode..."
  ch_log "***"
  cd src
  mkdir attract;cd attract
  ch_log "*** Attract-Mode - Getting sources"
  wget https://github.com/mickelson/attract/archive/master.zip
  unzip master.zip;rm master.zip;cd attract-master/
  ch_log "*** Attract-Mode - make"
  make -j4 USE_GLES=1 &>> ${CH_LOGFILE}
  ch_log "*** Attract-mode - Set config and binary..."
  cp -va config /usr/local/share/attract &>> ${CH_LOGFILE}
  cp -v attract ${CH_ROOT}/bin &>> ${CH_LOGFILE}
  cd ${CH_ROOT}
  #to start for first time: attract -f DejaVuSans
  ch_log "*** Attract-mode deploy finished."
}

function ch_deploy_retroarch {
  ch_log "***"
  ch_log "*** Deploying Retroarch..."
  ch_log "***"
  # Retroarch
  cd ${CH_ROOT}/src
  mkdir retroarch;cd retroarch
  ch_log "*** Retroarch - Getting sources..."
  wget https://github.com/libretro/RetroArch/archive/master.zip
  unzip master.zip > /dev/null
  rm -f master.zip
  cd RetroArch-master/
  ch_log "*** Retroarch - ./configure"
  ./configure --disable-xmb --enable-dispmanx --enable-opengles --disable-pulse --disable-oss --enable-neon --enable-floathard &>> ${CH_LOGFILE}
  ch_log "*** Retroarch - make"
  make -j4 &>> ${CH_LOGFILE}
  cp -v retroarch ${CH_ROOT}/bin/
  cd ${CH_ROOT}
  ch_log "*** Retroarch deploy finished."
}

function ch_printusage {
  echo "** Usage:"
  echo "\tchuardeploy.sh all\tDeploy everything"
  echo "\tchuardeploy.sh <component>\tInstall specific component. Not yet implemented."
  echo "\tchuardeploy.sh -h\tThis help."
}

#
# IMPLEMENTATION
#
case $1 in
  "-h"|"help"|"--help")
    ch_printusage
	exit 0
	;;
  "all")
    ch_deploy_prepare
    ch_deploy_sdl2
    ch_deploy_sfmlpi
    ch_deploy_ffmpeg
    ch_deploy_attract
    ch_deploy_retroarch
    ;;
  *)
    ch_printusage
	exit 1
	;;
esac
