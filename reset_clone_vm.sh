#!/bin/bash
# This script is paired with the vm base template setup 
# steps it means if you need to update a vm template then run this 
# afterwards so you can use the image for cloning again
#

rclocal() {
	echo "Putting firstboot back"
	cat > /etc/rc.local << EOF
	/usr/local/sbin/firstboot.sh 
	exit 0
	EOF
}

firstboot() {
	echo "Setting up firstboot and removing persistent net rules"
	echo ' ' > /etc/issue
	mv /usr/local/sbin/firstboot_done /usr/local/sbin/firstboot.sh
	chmod +x /usr/local/sbin/firstboot.sh
	rm -f /etc/udev/rules.d/70-persistent-net.rules
	update-alternatives --set editor /usr/bin/vim.basic
}

stopvm() {
	echo "NOW YOU CAN USE THIS FOR CLONING AGAIN"
	shutdown -h now
}

rclocal
firstboot
stopvm

