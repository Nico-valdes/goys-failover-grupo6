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
/port
set 0 name=serial0
/ip neighbor discovery-settings
set discover-interface-list=none
/ip address
add address=4.4.4.4 interface=lo0 network=4.4.4.4
add address=10.0.0.2/30 interface=ether1 network=10.0.0.0
add address=10.0.0.9/30 interface=ether2 network=10.0.0.8
add address=10.0.0.13/30 interface=ether3 network=10.0.0.12
add address=10.0.0.17/30 interface=ether4 network=10.0.0.16
/ip dhcp-client
add interface=ether1
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/routing ospf instance
add disabled=no name=ospf-main router-id=4.4.4.4
/routing ospf area
add area-id=0.0.0.0 disabled=no instance=ospf-main name=backbone
/routing ospf interface-template
add area=backbone auth=md5 auth-key=Goys2026OspfPass interfaces=ether1,ether2,ether3,ether4 type=ptp
add area=backbone interfaces=lo0 passive
/system identity
set name=CORE-1
/system note
set show-at-login=no
