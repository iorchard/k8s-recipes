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
* python3-apt: (optional) required for dry-run (--check option)

The ansible user should be on every machine and have sudo privilege.

I'll use a vault for ssh and sudo password.

I'll use passphrase-protected ssh keys to log into remote machines.

There are 3 groups - deployer, controllers, workers.

* deployer: the machine to run playbooks.
* controllers: the machines where controller components (mon, mds, mgr)
  are running.
* workers: the machines where osd components are running.

Preflight
----------

Create ssh key pair with passphrase.::

    $ ssh-keygen

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

    $ ansible-playbook --ask-vault-pass worker.yml
    $ ansible-playbook --ask-vault-pass controller.yml

Tear down the cluster.::

    $ ansible-playbook --ask-vault-pass site.yml --tags=teardown

