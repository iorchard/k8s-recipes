#!/usr/bin/env python

import os

# common
DPKG_DIR = os.path.join(os.path.abspath('.'), 'debs')

# build 
VER = '14.2.0'
DOCKER_IMG = 'ceph-builder'

# push
REPO_UID = 'jijisa'
REPO_SERVER = 'repo'
REPO_DIR = '/repos/iorchard/ceph'
REPO_NAME = 'iorchard-repo'
