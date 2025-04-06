#!/bin/bash
#--
# Script to help you prepare chrooted environment
#--
# Configuration and Mounting of directories
#--
CHROOT_DIR=$1
CHROOT_ACTION=$2 # MOUNT (default), UMOUNT
#--
if [[ $CHROOT_ACTION == '' ]]; then
	CHROOT_ACTION='MOUNT'
fi
#--
if [[ $CHROOT_DIR == '' ]]; then
	echo "Usage ex.: "$0" /mnt/yourChrootDirectory [MOUNT|UMOUNT]"
	exit
fi

#--
echo "DEBUG OPTIONS..."
echo "--------------------------------------------"
echo "CHROOT_DIR: "$CHROOT_DIR
echo "CHROOT_ACTION: "$CHROOT_ACTION
echo "Is correct? (y/n)"
read -r CHK
if [[ $CHK != 'y' ]]; then
	echo "Exiting..."
	exit
fi

if [[ $CHROOT_ACTION == 'MOUNT' ]]; then
	echo "Running MOUNT"
	mount --rbind /dev $CHROOT_DIR"/dev"
#	mount --make-rslave $CHROOT_DIR"/dev"
	mount --rbind /dev/pts $CHROOT_DIR"/dev/pts"
	mount -t proc /proc $CHROOT_DIR"/proc"
	mount --rbind /sys $CHROOT_DIR"/sys"
#	mount --make-rslave $CHROOT_DIR"/sys"
#	mount --rbind /tmp $CHROOT_DIR"/tmp"
#	mount --bind /run $CHROOT_DIR"/run"
elif [[ $CHROOT_ACTION == 'UMOUNT' ]]; then
	echo "Running UMOUNT"
	umount -l $CHROOT_DIR"/dev/pts"
	umount -l $CHROOT_DIR"/dev"
	umount -l $CHROOT_DIR"/proc"
	umount -l $CHROOT_DIR"/sys"
	umount -l $CHROOT_DIR"/tmp"
	umount -l $CHROOT_DIR"/run"
	exit
else
	echo "Unknown CHROOT_ACTION: "$CHROOT_ACTION
	exit
fi

echo "Next thing is to create or copy /etc/portage/make.conf and /etc/resolv.conf."
echo "Then run: "
echo "chroot "$CHROOT_DIR" /bin/bash"
echo ""
echo "Add these to /root/.bashrc to set automaticaly on chroot: "
echo ". /etc/profile"
echo "export PS1=\"(chroot) \"\$PS1"
echo ""
echo "Thats it. You have chrooted environment."
echo ""
echo "First time dont forget to edit /etc/resolv.conf and run"
echo "emerge-webrsync && emerge --sync"
echo "With running of emerge-webrsync we set our profile on /etc/portage/make.profile"
