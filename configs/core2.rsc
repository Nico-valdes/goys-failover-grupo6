# 2026-10-08 07:57:08 by RouterOS 7.16
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
add address=5.5.5.5 interface=lo0 network=5.5.5.5
add address=10.0.0.6/30 interface=ether1 network=10.0.0.4
add address=10.0.0.10/30 interface=ether2 network=10.0.0.8
add address=10.0.0.21/30 interface=ether3 network=10.0.0.20
add address=10.0.0.25/30 interface=ether4 network=10.0.0.24
/ip dhcp-client
add interface=ether1
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/system identity
set name=CORE-2
/system note
set show-at-login=no