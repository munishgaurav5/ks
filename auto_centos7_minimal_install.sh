#/bin/bash

# author: François Cami <fcami@fedoraproject.org>
# License: MIT

# see README.md

#export INSTALL_SRV="http://KICKSTART_SRV_FQDN/"

export KSURL="https://github.com/munishgaurav5/ks/raw/master/auto_centos7_minimal.cfg"
export DNS1=8.8.8.8
export DNS2=8.8.4.4

#export MIRROR="http://mirror.ircam.fr/pub/CentOS/7.2.1511/os/x86_64/"
export MIRROR="http://mirror.nl.leaseweb.net/centos/7/os/x86_64/"

export IPADDR=$(ip a s eth0 |grep "inet "|awk '{print $2}'| awk -F '/' '{print $1}')
export PREFIX=$(ip a s eth0 |grep "inet "|awk '{print $2}'| awk -F '/' '{print $2}')
export GW=$(ip route|grep default | awk '{print $3}')

curl -o /boot/vmlinuz ${MIRROR}images/pxeboot/vmlinuz
curl -o /boot/initrd.img ${MIRROR}images/pxeboot/initrd.img

#    linux /vmlinuz net.ifnames=0 biosdevname=0 ip=${IPADDR}::${GW}:${PREFIX}:$(hostname):eth0:off nameserver=$DNS1 nameserver=$DNS2 inst.repo=$MIRROR inst.ks=$KSURL
# inst.vncconnect=${IPADDR}:5500 # inst.vnc inst.vncpassword=changeme headless
# inst.vnc inst.vncpassword=changeme inst.headless  inst.lang=en_US inst.keymap=us

cat << EOF >> /etc/grub.d/40_custom
menuentry "reinstall" {
    set root=(hd0,1)
    linux /vmlinuz net.ifnames=0 biosdevname=0 ip=${IPADDR}::${GW}:${PREFIX}:$(hostname):eth0:off nameserver=$DNS1 nameserver=$DNS2 inst.repo=$MIRROR inst.ks=$KSURL inst.vnc inst.vncconnect=${IPADDR}:1 inst.vncpassword=changeme inst.headless inst.lang=en_US inst.keymap=us 
    initrd /initrd.img
}
EOF

sed -i -e "s/GRUB_DEFAULT.*/GRUB_DEFAULT=\"reinstall\"/g" /etc/default/grub

grub2-mkconfig
grub2-mkconfig --output=/boot/grub2/grub.cfg

echo ""
echo ""
echo " >>> Manually update 'IP, Gateway & Hostname' in kickstart config file .. <<<"
echo "IP : $IPADDR"
echo "Gateway : $GW"
echo ""
echo "DONE!"

