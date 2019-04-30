Robot recipe
==============

Robot Framework is a robotic process/test automation tool.
This recipe uses sshlibrary to update our local debian mirror.

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

Run
-----

To update our local mirror::

    (robot) $ read -s -p 'mirror server pw: ' REPO_PW
    mirror server pw: 
    (robot) $ export REPO_PW
    (robot) $ robot -d output update.robot
    (robot) $ unset REPO_PW

