#!/usr/bin/bash
# mounts a disk image or unmounts it default dir it mounts
# to is mounted_Image 
# zero args umounts the disk image and preforms cleanup

mountPoint=mounted_Image/

# moutning vm disk image
[[ $# -ne 0 ]] && 
	(echo modprobing && 
	sudo modprobe nbd &&  # setup
	echo connecting $1&& 
	sudo qemu-nbd --connect=/dev/nbd0 "$1" && 
	a=$(sudo fdisk /dev/nbd0 -l --bytes -o device,size |  #get partition name
		sed -e '1,8s/.*//g' | 
		sed -r '/^\s*$/d' | 
		sort | 
		fzf) && 
	a=$(echo $a | sed '/\ .*//g') && 
	echo $a && 
	echo mounting && 
	sudo mount "$a" -r "$mountPoint" &&  #mount partition
	exit || 
	echo canceling) #cancel conditional


# unmount vm disk image
[[ $# -lt 1 ]] && 
	sudo umount "$mountPoint" && 
	echo umounting "$mountPoint"

# cleanup
sudo qemu-nbd --disconnect /dev/nbd0
sudo rmmod nbd && 
	echo rmmod
