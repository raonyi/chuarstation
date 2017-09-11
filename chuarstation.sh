#!/bin/bash
#
# Chuarstation deployment - R. 05-09-17
# Created for: Raspbian Stretch Lite 2017-09-07 on Raspberry Pi 3
#

# Initial config
sudo -s
useradd -d /opt/chuarstation -s /bin/bash chuarstation
mkdir /opt/chuarstation
chown -R chuarstation. /opt/chuarstation
passwd chuarstation
passwd
systemctl enable ssh
systemctl restart ssh
apt update;apt upgrade -y
#--reboot now
rpi-update
#--reboot now

# Login as 'chuarstation' and continue

# Dependencies and tools
sudo apt install -y git vim screen nmap tcpdump cmake fontconfig libasound2-dev
sudo apt install -y libflac-dev libogg-dev libvorbis-dev libopenal-dev
sudo apt install -y libjpeg8-dev libfreetype6-dev libudev-dev libraspberrypi-dev

# Chuarstation base tree and config
echo 'export PATH="$PATH:/opt/chuarstation/bin"' >> .bash_profile
mkdir /opt/chuarstation/bin
mkdir /opt/chuarstation/etc
mkdir /opt/chuarstation/games
mkdir /opt/chuarstation/misc
mkdir /opt/chuarstation/src

# SDL
mkdir /opt/chuarstation/src/sdl
cd /opt/chuarstation/src/sdl
wget https://www.libsdl.org/release/SDL2-2.0.5.tar.gz
tar -xvzf SDL2-2.0.5.tar.gz
rm SDL2-2.0.5.tar.gz
cd SDL2-2.0.5/
mkdir build;cd build
cmake ../
make -j3 | tee makesdl.log
sudo ake install
sudo ldconfig
cd ../../../..

# SFML-PI
mkdir src/sfml-pi;cd src/sfml-pi/
wget https://github.com/mickelson/sfml-pi/archive/master.zip
unzip master.zip
rm master.zip
cd sfml-pi-master
mkdir build;cd build
cmake ../ -DSFML_RPI=1 -DEGL_INCLUDE_DIR=/opt/vc/include -DEGL_LIBRARY=/opt/vc/lib/libEGL.so -DGLES_INCLUDE_DIR=/opt/vc/include -DGLES_LIBRARY=/opt/vc/lib/libGLESv2.so -DGLES2_LIBRARY=/opt/vc/lib/libGLESv2.so
make -j4 | tee makesfmlpi.log
sudo make install
sudo ldconfig
cd /opt/chuarstation

# FFMPEG
cd src
mkdir ffmpeg;cd ffmpeg
wget https://github.com/FFmpeg/FFmpeg/archive/master.zip
unzip master.zip;rm master.zip;cd FFmpeg-master/
./configure --enable-mmal --enable-shared
make -j4 | tee makeffmpeg.log
sudo make install
sudo ldconfig
cd /opt/chuarstation

# Attract-Mode
cd src
mkdir attract;cd attract
wget https://github.com/mickelson/attract/archive/master.zip
unzip master.zip;rm master.zip;cd attract-master/
make -j4 USE_GLES=1 | tee makeattract.log
sudo cp -a config /usr/local/share/attract
cp attract /opt/chuarstation/bin
cd /opt/chuarstation/
#to start for first time: attract -f DejaVuSans

# Retroarch
cd src
mkdir retroarch;cd retroarch
wget https://github.com/libretro/RetroArch/archive/master.zip
unzip master.zip;rm -f master.zip
cd RetroArch-master/
./configure --disable-xmb --enable-dispmanx --enable-opengles --disable-pulse --disable-oss --enable-neon --enable-floathard
make -j4 | tee makeretroarch.log
mkdir /opt/chuarstation/emu/ra
cp retroarch /opt/chuarstation/bin/
