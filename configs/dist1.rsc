# 2026-10-22 20:15:00 by RouterOS 7.16
# software id = 
#
/interface bridge
add name=lo0
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/interface vrrp
add authentication=simple interface=ether3 name=vrrp10-users password=Vrrp10 priority=150 version=2 vrid=10
add authentication=simple interface=ether4 name=vrrp20-servers password=Vrrp20 priority=100 version=2 vrid=20
/port
set 0 name=serial0
/ip neighbor discovery-settings
set discover-interface-list=none
/ip address
add address=6.6.6.6 interface=lo0 network=6.6.6.6
add address=10.0.0.14/30 interface=ether1 network=10.0.0.12
add address=10.0.0.22/30 interface=ether2 network=10.0.0.20
add address=192.168.10.2/24 interface=ether3 network=192.168.10.0
add address=192.168.20.2/24 interface=ether4 network=192.168.20.0
add address=192.168.10.1/24 interface=vrrp10-users network=192.168.10.0
add address=192.168.20.1/24 interface=vrrp20-servers network=192.168.20.0
/ip dhcp-client
add interface=ether1
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/routing ospf instance
add disabled=no name=ospf-main router-id=6.6.6.6
/routing ospf area
add area-id=0.0.0.0 disabled=no instance=ospf-main name=backbone
/routing ospf interface-template
add area=backbone auth=md5 auth-key=Goys2026OspfPass interfaces=ether1,ether2 type=ptp
add area=backbone interfaces=lo0,ether3,ether4 passive
/system identity
set name=DIST-1
/system note
set show-at-login=no
