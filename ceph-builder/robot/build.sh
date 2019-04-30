#!/bin/sh

set -e 

# variables.
URL="https://download.ceph.com/tarballs"
VER=$1
TARBALL="ceph-${VER}.tar.gz"

BUILD_DIR="/tmp/ceph"
BIN_DIR="/debs"
INSTALL_DEPS="install-deps-stretch.sh"

apt update
apt install -y curl python python3
mkdir -p ${BUILD_DIR}

# Download 
curl -o /tmp/${TARBALL} ${URL}/${TARBALL}

tar -C ${BUILD_DIR} -xzf /tmp/${TARBALL}

cp /${INSTALL_DEPS} ${BUILD_DIR}/ceph-${VER}/

cd ${BUILD_DIR}/ceph-${VER}
./${INSTALL_DEPS}
dpkg-buildpackage -uc -us

mkdir -p ${BIN_DIR}
cp ${BUILD_DIR}/*.deb ${BIN_DIR}/

