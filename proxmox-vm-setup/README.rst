TACO VM Setup
==============

This is the robot sources to set up virtual machines on proxmox server
for TACO testing.

It uses Robot Framework which is a robotic process/test automation tool.

Pre-requisite
--------------

Install robot framework. I always create virtual env to 
have python environment.::

    $ sudo apt update && sudo apt install -y python3-venv
    $ mkdir .envs
    $ pyvenv .envs/robot
    $ source .envs/robot/bin/activate
    (robot) $ pip install wheel
    (robot) $ pip install robotframework 
                          robotframework-sshlibrary \
                          cryptography==2.4.2 

cryptography 2.5 and above are not compatible with paramiko
that robotframeowrk-sshlibrary uses so install 2.4.2 version.

Create VMs
-----------

Open props.py and Change variable as your testbed environment.::

    $ vi props.py
    ...
    # VM ID (The first ID only)
    ID = 9030
    PREFIX = 'taco3-'

Run setup.robot to create virtual machines.::

    (robot) $ robot -d output setup.robot

After robot works are done, you can see the vm list with qm command.::

    (robot) $ sudo qm list
    

