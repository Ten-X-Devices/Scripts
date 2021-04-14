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
  nano tenx_$newdevice.txt
}

# Push to GitHub
function push_all() {
git add .
if [[ $ch -eq 1 ]]; then
    git commit -m "$commit_message [TenX-CI] Update $devicename [$date]"
else
    git commit -m "$commit_message [TenX-CI] Add $newdevice [$date]"
fi
git push -f origin HEAD:master
}

# Functiom rm all
function rm_all() {
cd ~
echo -e "Removing Changelogs files"
rm -rf Changelogs
rm -rf generator.sh
}

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

if [[ "ch" = "1" ]]; then
   read_device
elif [[ "ch" = "2" ]]; then
   create_device
else
push_all
rm_all
exit
fi
}

options
read_device
create_device
