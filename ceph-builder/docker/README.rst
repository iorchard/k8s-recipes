Docker recipe
==============

It builds ceph debian packages to be used in debian 9 stretch machine.

When job is completed, ceph debian packages are in 
/var/lib/docker/volumes/debs/_data/ directory.

To Build
---------

Create a container image using docker build.::

    docker build -t ceph-builder:1.0 .

See the newly created image.::

    $ docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    ceph-builder        1.0                 32caca4a55bb        48 seconds ago      175MB
    debian              stretch             2d337f242f07        3 days ago          101MB

How to run a container to build ceph on debian stretch:

    docker run -v debs:/debs --rm ceph-builder:1.0 <ceph_version>

For example, run a container to build ceph 14.2.0.::

    $ docker run \
        -d \
        --rm \
        -v debs:/debs \
        ceph-builder:1.0 \
        14.2.0

Building ceph takes a long time. 
My docker machine is a virtual machine with 8 cores, 32G RAM, 100G disk.
It took one and a half hours to build on it.
