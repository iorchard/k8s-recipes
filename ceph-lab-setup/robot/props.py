#!/usr/bin/env python
# debian openstack image 
# disk total size: 2G
# Login account: debian
DEB_IMG_URL = 'http://cdimage.debian.org/cdimage/openstack/current'
DEB_VER = '9.9.0'
DEB_ARCH = 'amd64'
DEB_KEYSERVER = 'keyring.debian.org'
DEB_KEYID = 'DF9B9C49EAA9298432589D76DA87E80D6294BE9B'

# user account to create in VM.
USERID = 'orchard'

# VM location and size.
SRC_DIR = '/data/kvm/images'
DST_DIR = '/data/kvm/ceph-lab'
SIZE = 10   # OSD disk size in GiB.

# Ceph cluster machine list.
VMS = [
        'ceph-admin1',
        'ceph-admin2',
        'ceph-admin3',
        'ceph-client1',
        'ceph1',
        'ceph2',
        'ceph3',
]

# Ceph machine role list.
ROLES = {
        'ceph-admin1': 'controller',
        'ceph-admin2': 'controller',
        'ceph-admin3': 'controller',
        'ceph-client1': 'client',
        'ceph1': 'worker',
        'ceph2': 'worker',
        'ceph3': 'worker',
}
# Ceph cluster machine IP list.
IPS = {
        'ceph-admin1': ['10.5.0.51', '192.168.24.51'],
        'ceph-admin2': ['10.5.0.52', '192.168.24.52'],
        'ceph-admin3': ['10.5.0.53', '192.168.24.53'],
        'ceph-client1': ['10.5.0.61', '192.168.24.61'],
        'ceph1': ['10.5.0.101', '192.168.24.101'],
        'ceph2': ['10.5.0.102', '192.168.24.102'],
        'ceph3': ['10.5.0.103', '192.168.24.103'],
}
