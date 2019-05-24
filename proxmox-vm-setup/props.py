#!/usr/bin/env python
import os

# VM ID (The first ID only)
ID = 9030
PREFIX = 'taco3-'

# Do not edit the below!!!
# debian openstack image 
# disk total size: 2G
# Login account: debian
DEB_IMG_URL = 'http://cdimage.debian.org/cdimage/openstack/current'
DEB_VER = '9.9.1'
DEB_ARCH = 'amd64'
DEB_TMPL_ID = 9001
DEB_TMPL_NAME = 'debian-{}-tmpl'.format(DEB_VER)
# centos openstack image 
# disk total size: 8G
# Login account: centos
CENTOS_IMG_URL = 'http://cloud.centos.org/centos/7/images'
CENTOS_VER = '7'
CENTOS_ARCH = 'x86_64'
CENTOS_TMPL_ID = 9000
CENTOS_TMPL_NAME = 'centos-{}-tmpl'.format(CENTOS_VER)

IMG_URL = CENTOS_IMG_URL
VER = CENTOS_VER
ARCH = CENTOS_ARCH
TMPL_ID = CENTOS_TMPL_ID
TMPL_NAME = CENTOS_TMPL_NAME

POOL = 'jijisa-pool'
STORAGE = 'local-lvm2'
VG = 'pve2'
THINPOOL = 'pve2/data2'

# VM location and size
IMG_DIR = os.environ.get('HOME', '.') + '/images'
SSHKEY = os.environ.get('HOME') + '/.ssh/id_rsa'
NAMESERVER = '8.8.8.8'
RESIZE = 100    # root partition resize in GiB
OSD_NUM = 3     # The number of osd disks.
OSD_SIZE = 50   # Storage additional 3 disks size in GiB.

MEMORY = 32*1024  # VM memory in MiB
CORES = 16  # VM cores

# TACO cluster machine list.
VMS = [
        PREFIX + 'master',
        PREFIX + 'node',
        #PREFIX + 'strg',
]
# Roles
ROLES = {
        PREFIX + 'master': ['master'],
        PREFIX + 'node': ['node', 'storage'],
        #PREFIX + 'strg': ['storage'],
}
# IP list
EXT_NET = '192.168.24'
INT_NET = '192.168.124'
VMBR0 = 'vmbr24'
VMBR1 = 'vmbr124'
GW = '192.168.24.1'
IP = ID - 9000
IPS = {
        PREFIX + 'master': [EXT_NET + '.' + str(IP), 
                            INT_NET + '.' + str(IP)],
        PREFIX + 'node': [EXT_NET + '.' + str(IP+1), 
                            INT_NET + '.' + str(IP+1)],
        #PREFIX + 'strg': [EXT_NET + '.' + str(IP+2), 
        #                    INT_NET + '.' + str(IP+2)],
}
