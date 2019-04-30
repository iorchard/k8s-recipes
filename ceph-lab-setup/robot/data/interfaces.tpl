# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# Management network interface
allow-hotplug ens2
iface ens2 inet static
	address IP1/8
	gateway 10.3.0.4
	# dns-* options are implemented by the resolvconf package, if installed
	dns-nameservers 164.124.101.2

# Storage network interface
allow-hotplug ens7
iface ens7 inet static
	address IP2/24
