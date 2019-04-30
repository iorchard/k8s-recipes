#!/usr/bin/env python

SRC_IMG = '/data/kvm/images/stretch_tmpl.qcow2'
DST_DIR = '/data/kvm/ceph-lab'
VM_MAN = '/data/kvm/scripts/vm_man.sh'

VMS = [
        'ceph-admin1',
        'ceph-admin2',
        'ceph-admin3',
        'ceph-client1',
        'ceph1',
        'ceph2',
        'ceph3',
]

IPS = {
        'ceph-admin1': ['10.5.0.51', '192.168.24.51'],
        'ceph-admin2': ['10.5.0.52', '192.168.24.52'],
        'ceph-admin3': ['10.5.0.53', '192.168.24.53'],
        'ceph-client1': ['10.5.0.61', '192.168.24.61'],
        'ceph1': ['10.5.0.101', '192.168.24.101'],
        'ceph2': ['10.5.0.102', '192.168.24.102'],
        'ceph3': ['10.5.0.103', '192.168.24.103'],
}
