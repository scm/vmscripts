#! /bin/sh
# Settings
UN=$1
PW=$2
SSHD_CONFDIR=/etc/ssh

# Generate new SSH host keys
gen_ssh_keys() {
	rm -f /etc/ssh/*key*
    echo "Generating DSA-Hostkey..."
    ssh-keygen -t dsa -N "" -f "${SSHD_CONFDIR}"/ssh_host_dsa_key || return 1

    echo "Generating RSA-Hostkey..."
    ssh-keygen -t rsa -N "" -f "${SSHD_CONFDIR}"/ssh_host_rsa_key || return 1

    echo "Generating ecdsa hostkey"
    ssh-keygen -t ecdsa -N "" -f "${SSHD_CONFDIR}"/ssh_host_ecdsa_key || return 1


    return 0
}

# issue-reset                    set ipaddr in /etc/issue
issue_gen() {
    cat /root/txt_message >> /etc/issue
    echo "CLONEDVM" >> /etc/issue
    uname -a >> /etc/issue
	sleep 5 
    echo " " >> /etc/issue
    /sbin/ifconfig | grep "inet addr" | grep -v "127.0.0.1" | awk '{ print $2 }' | awk -F: '{ print $2 }' >> /etc/issue
    echo " " >> /etc/issue
    echo "Have a good time!" >> /etc/issue
    echo "default username: $UN" >> /etc/issue
    echo "default password: $PW" >> /etc/issue
    echo "****************************" >> /etc/issue
    cp /etc/issue /etc/issue.net
}

# Never run this script on boot again
clean_me() {
	echo "# Put your special scripts that you can't make into real init scripts here:" > /etc/rc.local ;
	echo "exit 0" >> /etc/rc.local ;
	chmod -x /usr/local/sbin/firstboot.sh && mv /usr/local/sbin/firstboot.sh /usr/local/sbin/firstboot_done
	logger "Removed firstboot script"
}

#functions
gen_ssh_keys
issue_gen
clean_me
