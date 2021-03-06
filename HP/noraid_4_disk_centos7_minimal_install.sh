#/bin/bash

# cd /tmp && wget https://raw.githubusercontent.com/munishgaurav5/ks/master/HP/noraid_4_disk_centos7_minimal_install.sh && chmod 777 noraid_4_disk_centos7_minimal_install.sh && ./noraid_4_disk_centos7_minimal_install.sh 

#export INSTALL_SRV="http://KICKSTART_SRV_FQDN/"
 

### NEW ###
yum -y install nano wget curl net-tools lsof bzip2 zip unzip rar unrar epel-release git sudo make cmake GeoIP sed at
###########

KSURL="https://raw.githubusercontent.com/munishgaurav5/ks/master/HP/noraid_4_disk_centos7_minimal.cfg"
DNS1=8.8.8.8
DNS2=8.8.4.4

MIRROR="http://mirror.nl.leaseweb.net/centos-vault/7.2.1511/isos/x86_64/"



#IPADDR=$(ip a s $NETWORK_INTERFACE_NAME |grep "inet "|awk '{print $2}'| awk -F '/' '{print $1}')
#PREFIX=$(ip a s $NETWORK_INTERFACE_NAME |grep "inet "|awk '{print $2}'| awk -F '/' '{print $2}')
#GW=$(ip route|grep default | awk '{print $3}')
#NETWORK_INTERFACE_NAME="$(ip -o -4 route show to default | awk '{print $5}')"

IPADDR=$(hostname -I | awk -F ' ' '{print $1}' | head -1)
GW=$(ip route|grep default | awk '{print $3}' | head -1)
NETWORK_INTERFACE_NAME="$(ip -o -4 route show to default | awk '{print $5}' | head -1)"
MASK=255.255.255.0
####
   while [[ $IP_CORRECT = "" ]]; do # to be replaced with regex       
       read -p "(1/4) SERVER MAIN IP is '${IPADDR}' (y/n) : " IP_CORRECT
   done

if [ $IP_CORRECT != "y" ]; then
   read -p "SERVER MAIN IP : " IPADDR
   #exit 1
   
      IP_CORRECT=
      while [[ $IP_CORRECT = "" ]]; do # to be replaced with regex       
       read -p "SERVER MAIN IP is '${IPADDR}' (y/n) : " IP_CORRECT
       #$MAIN_IP
      done
fi

if [ $IP_CORRECT != "y" ]; then
   #read -p "SERVER IP : " MAIN_IP
   echo "Error!... Try Again!"
   exit 1
fi
####

#   while [[ $PREFIX_CORRECT = "" ]]; do # to be replaced with regex       
#       read -p "(2/4) SERVER IP PREFIX is '${PREFIX}' (y/n) : " PREFIX_CORRECT
#   done

#if [ $PREFIX_CORRECT != "y" ]; then
#   read -p "SERVER IP PREFIX : " PREFIX
#   #exit 1
   
#      PREFIX_CORRECT=
#      while [[ $PREFIX_CORRECT = "" ]]; do # to be replaced with regex       
#       read -p "SERVER IP PREFIX is '${PREFIX}' (y/n) : " PREFIX_CORRECT
#       #$MAIN_IP
#      done
#fi

#if [ $PREFIX_CORRECT != "y" ]; then
#   #read -p "SERVER IP : " MAIN_IP
#   echo "Error!... Try Again!"
#   exit 1
#fi
####
   while [[ $GW_CORRECT = "" ]]; do # to be replaced with regex       
       read -p "(3/4) SERVER IP Gayeway is '${GW}' (y/n) : " GW_CORRECT
   done

if [ $GW_CORRECT != "y" ]; then
   read -p "IP Gayeway : " GW
   #exit 1
   
      GW_CORRECT=
      while [[ $GW_CORRECT = "" ]]; do # to be replaced with regex       
       read -p "SERVER IP Gayeway is '${GW}' (y/n) : " GW_CORRECT
       #$MAIN_IP
      done
fi

if [ $GW_CORRECT != "y" ]; then
   #read -p "SERVER IP : " MAIN_IP
   echo "Error!... Try Again!"
   exit 1
fi
####

   while [[ $NETWORK_CORRECT = "" ]]; do # to be replaced with regex       
       read -p "(4/4) SERVER NETWORK INTERFACE NAME is '${NETWORK_INTERFACE_NAME}' (y/n) : " NETWORK_CORRECT
   done

if [ $NETWORK_CORRECT != "y" ]; then
   read -p "NETWORK INTERFACE NAME : " NETWORK_INTERFACE_NAME
   #exit 1
   
      NETWORK_CORRECT=
      while [[ $NETWORK_CORRECT = "" ]]; do # to be replaced with regex       
       read -p "SERVER NETWORK INTERFACE NAME is '${NETWORK_INTERFACE_NAME}' (y/n) : " NETWORK_CORRECT
       #$MAIN_IP
      done
fi

if [ $NETWORK_CORRECT != "y" ]; then
   #read -p "SERVER IP : " MAIN_IP
   echo "Error!... Try Again!"
   exit 1
fi
####
    
curl -o /boot/vmlinuz ${MIRROR}images/pxeboot/vmlinuz
curl -o /boot/initrd.img ${MIRROR}images/pxeboot/initrd.img


#    linux /vmlinuz net.ifnames=0 biosdevname=0 ip=${IPADDR}::${GW}:${PREFIX}:$(hostname):eth0:off nameserver=$DNS1 nameserver=$DNS2 inst.repo=$MIRROR inst.ks=$KSURL
# inst.vncconnect=${IPADDR}:5500 # inst.vnc inst.vncpassword=changeme headless
# inst.vnc inst.vncpassword=changeme inst.headless  inst.lang=en_US inst.keymap=us


echo ""
echo ""
root_value=`grep "set root=" /boot/grub2/grub.cfg | head -1`
echo "$root_value"
echo ""
echo ""
sleep 5
echo ""

Boot_device=${NETWORK_INTERFACE_NAME}
#Boot_device="eth0"

cat << EOF >> /etc/grub.d/40_custom
menuentry "reinstall" {
    $root_value
    linux /vmlinuz net.ifnames=0 biosdevname=0 ip=${IPADDR}::${GW}:${MASK}:$(hostname):$Boot_device:off nameserver=$DNS1 nameserver=$DNS2 inst.repo=$MIRROR inst.ks=$KSURL inst.vnc inst.vncconnect=${IPADDR}:1 inst.vncpassword=changeme inst.headless inst.lang=en_US inst.keymap=us 
    initrd /initrd.img
}
EOF


#sed -i -e "s/GRUB_DEFAULT.*/GRUB_DEFAULT=\"reinstall\"/g" /etc/default/grub

grub2-mkconfig
grub2-mkconfig --output=/boot/grub2/grub.cfg

grubby --info=ALL

echo ""
echo ""
echo "Setting Up default Grub Entry ..."
echo ""

sleep 5
echo ""

# install grub-customizer

### Permanent Boot Change
#grubby --default-index
#grub2-set-default 'reinstall'
#grubby --default-index

### Permanent Boot Change
#grubby --default-index
#grubby --set-default /boot/vmlinuz
#grubby --default-index

### One Time Boot Change
grubby --default-index
#grub-reboot 1
grub2-reboot  "reinstall"
grubby --default-index

echo ""
echo ""
echo " >>> Manually update 'IP, Gateway & Hostname' in kickstart config file .. <<<"
echo "IP : $IPADDR"
echo "Gateway : $GW"
echo "Network Interface : $NETWORK_INTERFACE_NAME" 
echo "Boot Drive Line : $root_value"
echo ""
echo "DONE!"
