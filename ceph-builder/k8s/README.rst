Kubernetes recipe
==================

It builds ceph debian packages to be used in debian 9 stretch machine.

When job is completed, ceph debian packages are in /debs at the worker node
where job runs. 

It uses hostPath so every worker node should have /debs directory.

To Build
---------

Apply manifest files in the following order.::

    $ kubectl apply -f cm_build.yml
    $ kubectl apply -f cm_install_deps_stretch.yml
    $ kubectl apply -f job_build.yml

Building ceph takes a long time. 
My kubernetes worker node is a virtual machine 
with 8 cores, 32G RAM, 100G disk.
It took one and a half hours to build on my server.
