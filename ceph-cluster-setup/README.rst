ceph-ansible
=============

This is the ansible playbook to install ceph cluster on debian 9
(stretch) machines.

Assumption
-----------

I assume all machines has a minimal debian stretch and  
the following packages are installed on every machine.

* ssh: required to run playbooks
* python3: required to run playbooks
* sshpass: required for ssh connection with password


These packages will be installed while running playbook.

* lvm2: required for workers to manage logical volumes.
* policykit-1: required to set timezone for all machines.
* python3-apt: required for dry-run (--check option) for all machines

The ansible user should be on every machine and have sudo privilege.

I'll use a vault for ssh and sudo password.

I'll use passphrase-protected ssh keys to log into remote machines.

There are 5 playbooks - deployer, controllers, workers, clients, setup.

* deployer: the machine to run playbooks.
* controllers: the machines where controller components (mon, mds, mgr)
  are running.
* clients: the machines mounting cephfs using ceph-fuse.
* workers: the machines where osd components are running.

Preflight
----------

Install pre-requisite packages.::

    $ sudo apt install -y python3-venv
    

Install ansible in virtualenv.::

    
    $ pyvenv ~/.envs/ansible
    $ source ~/.envs/ansible/bin/activate
    (ansible) $ pip install wheel
    (ansible) $ pip install ansible

Create ssh key pair with passphrase.::

    $ ssh-keygen
    Generating public/private rsa key pair.
    Enter file in which to save the key (/home/orchard/.ssh/id_rsa):     
    Created directory '/home/orchard/.ssh'.
    Enter passphrase (empty for no passphrase): 
    Enter same passphrase again: 

Create a vault file for ssh and sudo password.::

    $ ansible-vault create inventories/staging/group_vars/all/vault.yml
    New Vault password: 
    Confirm New Vault password: 
    ssh_pass: '<ssh password>'
    sudo_pass: '<sudo password>'

Edit files in inventories/{staging,prodution}/ as your environment.

Run
----

Run ssh-agent and add private key.::

    $ eval "$(ssh-agent -s)"
    $ ssh-add 
    Enter passphrase: (Enter your passphrase of ssh key)

Check before running playbooks.::

    $ ansible-playbook --ask-vault-pass site.yml --check

Run playbooks.::

    $ ansible-playbook --ask-vault-pass site.yml


Run the specific playbook.::

    $ ansible-playbook --ask-vault-pass controllers.yml
    $ ansible-playbook --ask-vault-pass workers.yml

Tear down the cluster.::

    $ ansible-playbook --ask-vault-pass site.yml --tags=teardown

