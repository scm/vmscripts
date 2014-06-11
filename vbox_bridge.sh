#!/bin/bash
# Stephen Murcott 
# 18/03/2014
# BSD 
#RUN THIS AS ROOT TO CREATE BRIDGES FOR VBOX VMS ON YOUR LOCAL MACHINE
# for this you need uml_utilities and bride_utils installed 
#
USER= # JUST PUT YOUR DESIRED USER HERE #`env | grep USER | cut -d= -f2`
INTERFACE=`route -n | awk 'FNR == 3{print $8}'`
ADDRESS=`ifconfig $INTERFACE | awk 'FNR == 2{print $2}'`
NETMASK=`ifconfig $INTERFACE | awk 'FNR == 2{print $4}'`
GATEWAY=`route -n | awk 'FNR == 3{print $2}'`
BROADCAST=`ifconfig $INTERFACE | awk 'FNR == 2{print $6}'`

echo "ENABLE TAP INTERFACES"
modprobe tun
tunctl -u $USER -t tap0
ifconfig tap0 0.0.0.0 promisc up
tunctl -u $USER -t tap1
ifconfig tap1 0.0.0.0 promisc up

chmod 0666 /dev/net/tun
echo "CREATE BRIDGE"
brctl addbr br0 
brctl addif br0 $INTERFACE
brctl addif br0 tap0
brctl addif br0 tap1

echo "CONFIGURE BRIDGE AND UP INTERFACES"
ifconfig br0 $ADDRESS netmask $NETMASK broadcast $BROADCAST up
ifconfig $INTERFACE 0.0.0.0 promisc up
echo "ADD DEFAULT ROUTE"
route add default gw $GATEWAY"
echo "DONE"
