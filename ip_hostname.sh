#!/bin/bash
#openssh packages and sshpass are needed for this to work
#speeding up vm hostname and ip configuration for use on vms
#
GW=$1
DNS=$2
UN=$3

TMP=tmp_dir
SSH_DIR=~/.ssh
PRIVKEY=id_rsa_setup

read -p "SET HOSTNAME: " HOSTNAME 
read -p "SET IP ADDRESS: " STATICIP
read -p "REMOTE HOST IP: " RHOST
read -p "REMOTE USER PASSWORD: " PASSWORD
	
 	if [ -d $TMP ]; then
		echo "$TMP exists!"
	else
		mkdir $TMP
	fi

create_confs(){
ssh-keygen -t rsa <<EOF
$SSH_DIR/$PRIVKEY
EOF

cat > $TMP/interfaces << EOF
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
address $STATICIP
netmask 255.255.0.0
gateway $GW 
dnsnameservers $DNS
EOF

cat > $TMP/hosts << EOF
127.0.0.1	localhost
127.0.1.1	$HOSTNAME.X.com $HOSTNAME
172.18.11.130 puppet.local.vmnet puppet
# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

cat > $TMP/hostname << EOF
$HOSTNAME
EOF

cat > $TMP/setup.sh << EOF
#!/bin/bash
sudo sed -i "s/$RHOST/$STATICIP/g" /etc/issue
sudo sed -i "s/$RHOST/$STATICIP/g" /etc/issue.net
sudo mv hosts /etc/hosts
sudo mv interfaces /etc/network/interfaces
sudo mv hostname /etc/hostname
echo "All Done Restarting Server"
sudo reboot
EOF

chmod +x $TMP/setup.sh

cat > $TMP/password.txt << EOF
$PASSWORD
EOF

echo "DONE CONFS"
}

send_confs(){
echo "COPY RSA ID"
sshpass -f $TMP/password.txt ssh-copy-id -i $SSH_DIR/id_rsa $UN@$RHOST
echo "SENDING CONFIGS"
scp $TMP/* $UN@$RHOST:./
echo "RUNNING CONFIGS"
ssh $UN@$RHOST "echo $PASSWORD | sudo -S sh setup.sh"
}

cleanup(){
echo "Cleaning up"
rm -f $SSH_DIR/$PRIVKEY
rm -f $SSH_DIR/$PRIVKEY.pub
rm -f $TMP/interfaces
rm -f $TMP/hostname
rm -f $TMP/hosts
rm -f $TMP/setup.sh
rm -f $TMP/password.txt
}

create_confs
send_confs
cleanup
