Ceph Lab Setup
===============

This is robot automation process for ceph cluster lab setup.

Here is the automated process.

#. Downloads the latest debian stable openstack image and SHA256 checksum
   and signature files.
#. Verify the checksum and image files.
#. Copy the downloaded source image to ceph VM images.
#. Create virsh xml file and interfaces file.
#. Manipulate ceph VM images with vm_man.sh script.
#. Define ceph VM.
#. Start ceph VM.

Before running robot files, edit the following files in data/ directory
for your environment.

* admin.tpl: virsh xml template for admin and client vm.
  You can change anything except capital letter placeholder variables 
  like NAME, UUID, MAC1, MAC2.
* osd.tpl: virsh xml template for osd vm.
  You can change anything except capital letter placeholder variables 
  like NAME, UUID, MAC1, MAC2.
* interfaces.tpl: template file for network setting.
  You can change anything except capital letter placeholder variables 
  like IP1, IP2
* grub: grub file to inject into all vm.

And you want to edit props.py as you want like 
USERID, SRC_DIR, DST_DIR, OSD_SIZE, VMS, ROLES, IPS.

To set up the ceph cluster.::

    (robot) $ read -s -p 'user pw: ' USERPW
    user pw: 
    (robot) $ export USERPW
    (robot) $ robot -d output setup.robot
    (robot) $ unset USERPW

USERPW variable should be set up before running robot tasks.

To tear down the ceph cluster.::

    (robot) $ robot -d output teardown.robot

