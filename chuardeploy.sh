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
# Main vars
CH_ROOT="/opt/chuarstation"
CH_LOGFILE="${CH_ROOT}/chuardeploy.log"
# Compilation vars


#
# FUNCTIONS
#
function ch_deploy_firstime_raspbian {
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
  # Dependencies and tools in a Raspbian environment
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
  # Vars
  CH_SDL2_SOURCES="https://www.libsdl.org/release/SDL2-2.0.5.tar.gz"
  CH_SDL2_CMAKE=""
  CH_SDL2_MAKE="-j4"
  
  # Implementation
  ch_log "***"
  ch_log "*** Deploying SDL2..."
  ch_log "***"
  mkdir -p ${CH_ROOT}/src/sdl2
  cd ${CH_ROOT}/src/sdl2
  # Get sources
  ch_log "*** SDL2 - Getting sources"
  wget "${CH_SDL2_SOURCES}"
  tar -xzf SDL2-2.0.5.tar.gz
  rm SDL2-2.0.5.tar.gz
  cd SDL2-2.0.5/
  # Prepare cmake environment
  ch_log "*** SDL2 - cmake"
  mkdir build;cd build
  cmake ../ ${CH_SDL2_CMAKE} &>> ${CH_LOGFILE}
  # Compile
  ch_log "*** SDL2 - make"
  make ${CH_SDL2_MAKE} &>> ${CH_LOGFILE}
  # Install system-wide
  ch_log "*** SDL2 - make install"
  make install &>> ${CH_LOGFILE}
  # Link shared libraries
  ch_log "*** SDL2 - ldconfig"
  ldconfig &>> ${CH_LOGFILE}
  cd ../../../..
  ch_log "*** SDL2 deploy finished."
}

function ch_deploy_sfmlpi { # Mickelson's SFML-PI
  # Vars
  CH_SFMLPI_SOURCES="https://github.com/mickelson/sfml-pi/archive/master.zip"
  CH_SFMLPI_CMAKE="-DSFML_RPI=1 -DEGL_INCLUDE_DIR=/opt/vc/include -DEGL_LIBRARY=/opt/vc/lib/libEGL.so -DGLES_INCLUDE_DIR=/opt/vc/include -DGLES_LIBRARY=/opt/vc/lib/libGLESv2.so -DGLES2_LIBRARY=/opt/vc/lib/libGLESv2.so"
  CH_SFMLPI_MAKE="-j4"

  # Implementation
  ch_log "***"
  ch_log "*** Deploying sfml-pi..."
  ch_log "***"
  mkdir src/sfml-pi;cd src/sfml-pi/
  # Get sources
  ch_log "*** sfml-pi - Getting sources..."
  wget "${CH_SFMLPI_SOURCES}"
  unzip master.zip > /dev/null # Prevent undesired output to screen
  rm master.zip
  cd sfml-pi-master
  # Prepare cmake environment
  ch_log "*** sfml-pi - cmake"
  mkdir build;cd build
  cmake ../ ${CH_SFMLPI_CMAKE} &>> ${CH_LOGFILE}
  ch_log "*** sfml-pi - make"
  # Compile
  make ${CH_SFMLPI_MAKE} &>> ${CH_LOGFILE}
  ch_log "*** sfml-pi - make install"
  # Install system-wide
  make install &>> ${CH_LOGFILE}
  ch_log "*** sfml-pi - ldconfig"
  # Link shared libraries
  ldconfig &>> ${CH_LOGFILE}
  cd ${CH_ROOT}
  ch_log "*** sfml-pi deploy finished."
}

function ch_deploy_ffmpeg {
  # Vars
  CH_FFMPEG_SOURCES="https://github.com/FFmpeg/FFmpeg/archive/master.zip"
  CH_FFMPEG_CONFIGURE="--enable-mmal --enable-shared"
  CH_FFMPEG_MAKE="-j4"
  
  # Implementation
  ch_log "***"
  ch_log "*** Deploying FFmpeg..."
  ch_log "***"
  # FFmpeg
  cd src
  mkdir ffmpeg;cd ffmpeg
  ch_log "*** FFmpeg - Getting sources..."
  wget ${CH_FFMPEG_SOURCES}
  unzip master.zip > /dev/null # Prevent undesired output to screen
  rm master.zip
  cd FFmpeg-master/
  ch_log "*** FFmpeg - ./configure"
  ./configure ${CH_FFMPEG_CONFIGURE} &>> ${CH_LOGFILE}
  ch_log "*** FFmpeg - make"
  make ${CH_FFMPEG_MAKE} &>> ${CH_LOGFILE}
  ch_log "*** FFmpeg - make install"
  make install &>> ${CH_LOGFILE}
  ch_log "*** FFmpeg - ldconfig"
  ldconfig &>> ${CH_LOGFILE}
  cd ${CH_ROOT}
  ch_log "*** FFmpeg deploy finished."
}
function ch_deploy_attract {
  # Vars
  CH_ATTRACT_SOURCES="https://github.com/mickelson/attract/archive/master.zip"
  CH_ATTRACT_MAKE="-j4 USE_GLES=1"
  
  # Implementation
  ch_log "***"
  ch_log "*** Deploying Attract-Mode..."
  ch_log "***"
  cd src
  mkdir attract;cd attract
  # Get sources
  ch_log "*** Attract-Mode - Getting sources"
  wget ${CH_ATTRACT_SOURCES}
  unzip master.zip > /dev/null # Prevent undesired output to screen
  rm master.zip
  cd attract-master/
  # Compile
  ch_log "*** Attract-Mode - make"
  make ${CH_ATTRACT_MAKE} &>> ${CH_LOGFILE}
  # Copy initial config in system shared folder and binary to CH_ROOT/bin
  ch_log "*** Attract-mode - Set config and binary..."
  cp -va config /usr/local/share/attract &>> ${CH_LOGFILE}
  cp -v attract ${CH_ROOT}/bin &>> ${CH_LOGFILE}
  cd ${CH_ROOT}
  #to start for first time: ./attract -f DejaVuSans
  ch_log "*** Attract-mode deploy finished."
}

function ch_deploy_retroarch {
  # Vars
  CH_RETROARCH_SOURCES="https://github.com/libretro/RetroArch/archive/master.zip"
  CH_RETROARCH_CONFIGURE="--disable-xmb --enable-dispmanx --enable-opengles --disable-pulse --disable-oss --enable-neon --enable-floathard"
  CH_RETROARCH_MAKE="-j4"
  
  # Implementation
  ch_log "***"
  ch_log "*** Deploying Retroarch..."
  ch_log "***"
  cd ${CH_ROOT}/src
  mkdir retroarch;cd retroarch
  # Get sources
  ch_log "*** Retroarch - Getting sources..."
  wget ${CH_RETROARCH_SOURCES}
  unzip master.zip > /dev/null # Prevent undesired output to screen
  rm -f master.zip
  cd RetroArch-master/
  # Configure and compile
  ch_log "*** Retroarch - ./configure"
  ./configure ${CH_RETROARCH_CONFIGURE} &>> ${CH_LOGFILE}
  ch_log "*** Retroarch - make"
  make ${CH_RETROARCH_MAKE} &>> ${CH_LOGFILE}
  # Move binary file to CH_ROOT/bin
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
    ch_deploy_sysupdate_raspbian
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
