Robot recipe
==============

This builds ceph debian packages to be used in debian 9 stretch machine.

Robot Framework is a robotic process/test automation tool.
This recipe uses docker to build and push the packages to our 
local debian mirror.


Pre-requisite
--------------

Install robot framework and ssh library. I always create virtual env to 
have python environment.::

    $ sudo apt update && sudo apt install -y python3-venv
    $ mkdir .envs
    $ pyvenv .envs/robot
    $ source .envs/robot/bin/activate
    (robot) $ pip install wheel \
                          robotframework \
                          robotframework-sshlibrary \
                          cryptography==2.4.2 \
                          docutils 

* wheel: wheel is needed when compile is needed for python module
* robotframework: no need to describe :)
* robotframework-sshlibrary: need it for connect and push deb files to mirror.
* cryptography: cryptography 2.5 and above are not compatible with paramiko
  that robotframeowrk-sshlibrary uses so installed 2.4.2.
* docutils: not needed if you do not use reST files with robotframework.
  If you do not know what reST files are, do not install it.

Build
------

Run build.robot to build ceph in docker container.::

    (robot) $ robot -d output build.robot


Building ceph takes a long time. 
My docker machine is a virtual machine with 8 cores, 32G RAM, 100G disk.
It took *one and a half hours* to build on it.

Push
-----

After building task is done, push the packages to our mirror.

push.robot uses REPO_PW environment variable.

So to push those packages to our local mirror::

    (robot) $ read -s -p 'mirror server pw: ' REPO_PW
    mirror server pw: 
    (robot) $ export REPO_PW
    (robot) $ robot -d output push.robot
    (robot) $ unset REPO_PW


To update mirror, refer to the recipe "mirror-update".

