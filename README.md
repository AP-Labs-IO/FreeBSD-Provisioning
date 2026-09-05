NFS Shares
==========

Configure and mount NFS shares.

Requirements
------------

* A supported release of FreeBSD (see [supported releases](https://www.freebsd.org/security/#sup)).
* An already bootstrapped FreeBSD environment, i.e.:
  * With a Python runtime.
  * With key-based SSH access.
  * A functional `become` setup.

The last set of requirements can be easily met by running the `ap_labs.bootstrap` as a precursor to this role.

Role Variables
--------------

None.

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `nfs_shares`: List of dictionaries with attributes:
    * `host`: Host that exports the target NFS share.
    * `src`: Path of the target NFS share within the host that exports it.
    * `path`: Path where the target NFS share should be mounted on the client.
    * `opts`: Mount options for the target NFS share.

Example Playbook
----------------

```yaml
---
- name: Bootstrap Node
  hosts: all
  become: false
  gather_facts: false
  vars: { ansible_user: root }
  roles:
    - { role: bootstrap, tags: [bootstrap] }

- name: Configure NFS shares
  hosts: all
  become: true
  roles:
    - { role: nfs_shares, tags: [nfs_shares] }
```

Execution
---------

Run the master orchestration playbook against your target inventory environment:

```sh
ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags nfs_shares playbook.yml
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
