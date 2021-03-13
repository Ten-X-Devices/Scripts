#!/bin/bash

# Changelog generator for TenX

cd ~

commit_message="Changelogs: "
date=$(date)

git clone https://github.com/Ten-X-Devices/TenX_Changelogs.git -b master Changelogs
cd ~/Changelogs

# Read device function
function read_device() {
  echo -e " Enter your existing device codename: "
  read devicename
  cd $devicename
  nano *
}

# Create device function
function create_device() {
  echo -e " Enter your new device codename: "
  read newdevice
  mkdir $newdevice
  cd $newdevice
  nano $newdevice.txt
}

# Push to GitHub
function push_all() {
git add .
if [[ $ch -eq 1 ]]; then
    git commit -m "$commit_message Update $devicename [$date]"
else
    git commit -m "$commit_message Add $newdevice [$date]"
fi
git push -f origin HEAD:master
}

# Ask them whether they have to create their device file or it's existing
function options() {
  echo -e " Create the file or it's existing "
  echo -e " 1.Existing"
  echo -e " 2.Create"
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

if [[ "ch" = "1" ]]; then
   read_device
elif [[ "ch" = "2" ]]; then
   create_device
   else
break
push_all
exit
fi
}

options
read_device
create_device
