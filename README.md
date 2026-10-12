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

The last set of requirements can be easily met by running the `ap_labs.bootstrap` role as a precursor to this one.

Role Variables
--------------

| Variable                | Default value | Description                                                                  |
|-------------------------|---------------|------------------------------------------------------------------------------|
| nfs_shares_access_cache | 5             | NFS access results caching, according to `nfs_access_cache` in `rc.conf(5)`. |
| nfs_shares_bufpackets   | 64            | Value of the `nfs_bufpackets` `rc.conf(5)` setting.                          |
| nfs_server_extra_kernel_settings | []   | See `nfs_server_extra_kernel_settings` below.                                |

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `nfs_shares`: List of dictionaries with attributes:
    * `host`: Host that exports the target NFS share.
    * `src`: Path of the target NFS share within the host that exports it.
    * `path`: Path where the target NFS share should be mounted on the client.
    * `opts`: Mount options for the target NFS share.
  * `nfs_server_extra_kernel_settings`: List of dictionaries with attributes:
    * `key`: Name of the runtime kernel tunable to set via `sysctl(8)`.
    * `value`: Value for `key` to set via the corresponding `sysctl(8)` invocation.
    * `description`: Optional description of the effect of setting `key` to `value` via `sysctl(8)`.

Example Ansible Configuration
-----------------------------

```ini
[defaults]
roles_path = ./roles

[privilege_escalation]
become = true
```

Example Requirements
--------------------

```yaml
---
- name: bootstrap
  src: git+ssh://git@gitlab.lan/ap-labs/ansible-roles/bootstrap.git
  version: main

- name: nfs_shares
  src: git+ssh://git@gitlab.lan/ap-labs/ansible-roles/nfs_shares.git
  version: main
```

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
  roles:
    - { role: nfs_shares, tags: [nfs_shares] }
```

Execution
---------

Run the master orchestration playbook against your target inventory environment:

```sh
-> ansible-galaxy role install -r requirements.yml -p ./roles
-> ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags nfs_shares playbook.yml
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
