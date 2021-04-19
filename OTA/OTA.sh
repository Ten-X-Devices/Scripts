#!/bin/bash

# OTA generator for TenX

cd ~

commit_message="OTA: "
date=$(date)

rm -rf ~/OTA*

git clone --quiet https://github.com/Ten-X-Devices/TenX_OTA.git -b master OTA > /dev/null
cd ~/OTA

format="https://raw.githubusercontent.com/Ten-X-Devices/TenX_OTA/master/Format/Format.json"

# Read device function
function read_device() {
  echo -e " Enter your existing device codename: "
  read devicename
}

# Create device function
function create_device() {
  echo -e " Enter your new device codename: "
  read newdevice
  mkdir $newdevice
  cd $newdevice
  wget -q $format 
  mv Format.json $newdevice.json
  nano $newdevice.json
}

# ROM dir
function rom_dir() {
  echo -e " Enter the name of ROM dir: "
  read dir
}

# Push to GitHub
function push_all() {
cd ~
cd OTA
git add .
if [[ $ch -eq 1 ]]; then
    git commit --quiet -m "$commit_message [TenX-CI] Update $devicename [$date]" --signoff > /dev/null
else
    git commit --quiet -m "$commit_message [TenX-CI] Add $newdevice [$date]" --signoff > /dev/null
fi
git push --quiet -u origin HEAD:master > /dev/null
}

# Function rm all
function rm_all() {
  cd ~
  echo -e "Removing OTA files"
  rm -rf OTA*
}

# Function gen OTA
function gen_ota() {
   cd ~
   zip_path=~/$dir/out/target/product/$devicename/TenX-OS_*.zip

   # Build ID
   build_id=`sha256sum $zip_path | cut -d' ' -f1`
   old_build_id=`cat ~/OTA/$devicename/$devicename.json | grep -w "id" | cut -d':' -f2 | cut -d'"' -f2`
   `sed -i "s|$old_build_id|$build_id|g" ~/OTA/$devicename/$devicename.json`

   # Filename
   file_name=`echo $zip_path | cut -d'/' -f9`
   old_file_name=`cat ~/OTA/$devicename/$devicename.json | grep "filename" | cut -d':' -f2 | cut -d'"' -f2`
   `sed -i "s|$old_file_name|$file_name|g" ~/OTA/$devicename/$devicename.json`

   # datetime
   date_time=`cat ~/$dir/out/target/product/$devicename/system/build.prop | grep ro.build.date.utc | cut -d'=' -f2`
   old_datetime=`cat ~/OTA/$devicename/$devicename.json | grep "datetime" | cut -d':' -f2 | cut -d',' -f1`
   `sed -i "s|$old_datetime|$date_time|g" ~/OTA/$devicename/$devicename.json`

   # Rom size
   size=`stat -c "%s" $zip_path`
   old_size=`cat ~/OTA/$devicename/$devicename.json | grep "size" | cut -d':' -f2 | cut -d',' -f1`
   `sed -i "s|$old_size|$size|g" ~/OTA/$devicename/$devicename.json`

   # url
   url="https://sourceforge.net/projects/tenx-os/files/$devicename/$file_name/download"
   old_url=`cat ~/OTA/$devicename/$devicename.json | grep -w url | cut -d '"' -f4`
   `sed -i "s|$old_url|$url|g" ~/OTA/$devicename/$devicename.json`

   # md5
   md5=`md5sum $zip_path | cut -d' ' -f1`
   old_md5=`cat ~/OTA/$devicename/$devicename.json | grep "filehash" | cut -d':' -f2 | cut -d'"' -f2`
   `sed -i "s|$old_md5|$md5|g" ~/OTA/$devicename/$devicename.json`
}

if [[ $ch -eq 1 ]]; then
   read_device
   dir
   gen_ota
fi

# Ask them whether they have to create their device file or it's existing
function options() {
  echo -e " Select the option "
  echo -e " 1.Existing device"
  echo -e " 2.Create a new device"
  read ch

case $ch in
  1)
  read_device
  ;;
  2)
  create_device
  ;;
  *)
  exit
  ::
esac

if [[ $ch -eq 1 ]]; then
   rom_dir
   gen_ota
fi
push_all
rm_all
exit
}

options
read_device
create_device
