# 2026-10-08 07:57:17 by RouterOS 7.16
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
add address=2.2.2.2 interface=lo0 network=2.2.2.2
add address=203.0.113.1/30 interface=ether1 network=203.0.113.0
/ip dhcp-client
add interface=ether1
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/system identity
set name=ISP-2
/system note
set show-at-login=no
