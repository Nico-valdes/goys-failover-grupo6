# 2026-10-23 00:25:00 by RouterOS 7.16
# software id = 
#
/interface bridge
add name=lo0
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/interface list
add name=WAN
add name=LAN
/interface list member
add interface=ether1 list=WAN
add interface=ether2 list=WAN
add interface=ether3 list=LAN
add interface=ether4 list=LAN
/port
set 0 name=serial0
/ip neighbor discovery-settings
set discover-interface-list=none
/ip address
add address=3.3.3.3 interface=lo0 network=3.3.3.3
add address=198.51.100.2/30 interface=ether1 network=198.51.100.0
add address=203.0.113.2/30 interface=ether2 network=203.0.113.0
add address=10.0.0.1/30 interface=ether3 network=10.0.0.0
add address=10.0.0.5/30 interface=ether4 network=10.0.0.4
/ip dhcp-client
add interface=ether1
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/ip firewall filter
add action=accept chain=input comment="Aceptar conexiones establecidas y relacionadas" connection-state=established,related
add action=drop chain=input comment="Descartar trafico invalido" connection-state=invalid
add action=accept chain=input comment="Permitir diagnostico ICMP" protocol=icmp
add action=accept chain=input comment="Permitir BGP desde ISPs" dst-port=179 in-interface-list=WAN protocol=tcp
add action=accept chain=input comment="Permitir OSPF desde Core interno" in-interface-list=LAN protocol=ospf
add action=accept chain=input comment="Permitir gestion desde LAN/Core" in-interface-list=LAN
add action=drop chain=input comment="Bloquear accesos no autorizados en WAN" in-interface-list=WAN
/routing filter rule
add chain=bgp-in-isp1 rule="set bgp-local-pref 200; accept;"
add chain=bgp-in-isp2 rule="set bgp-local-pref 100; accept;"
/routing bgp template
add as=65000 name=bgp-tmpl-edge router-id=3.3.3.3
/routing bgp connection
add input.filter=bgp-in-isp1 local.role=ebgp name=bgp-isp1 output.redistribute=ospf remote.address=198.51.100.1 .as=65001 tcp-md5-key=BgpSecret2026Edge templates=bgp-tmpl-edge
add input.filter=bgp-in-isp2 local.role=ebgp name=bgp-isp2 output.redistribute=ospf remote.address=203.0.113.1 .as=65002 tcp-md5-key=BgpSecret2026Edge templates=bgp-tmpl-edge
/routing ospf instance
add disabled=no name=ospf-main originate-default=always router-id=3.3.3.3
/routing ospf area
add area-id=0.0.0.0 disabled=no instance=ospf-main name=backbone
/routing ospf interface-template
add area=backbone auth=md5 auth-key=Goys2026OspfPass interfaces=ether3,ether4 type=ptp
add area=backbone interfaces=lo0 passive
/system identity
set name=EDGE
/system note
set show-at-login=no
