 modprobe bonding mode=1
 ifconfig bond0 0 up
 ifenslave bond0 tap0
 ifconfig tap0 up
 ifconfig bond0 192.168.0.1/24 up
 ip link add link bond0 name bond0.100 type vlan id 100
 ifconfig bond0.100 192.168.1.1/24 up
