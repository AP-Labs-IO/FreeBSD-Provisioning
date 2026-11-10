NFS Client
==========

Configure an NFS client and mount shares.

Requirements
------------

* An already bootstrapped FreeBSD environment, i.e.:
  * With a Python runtime.
  * With key-based SSH access.
  * A functional `become` setup.

The last set of requirements can be easily met by running the `ap_labs.freebsd_provisioning.bootstrap` role as a precursor to this one.

Role Variables
--------------

| Variable                         | Default value | Description                                                                  |
|----------------------------------|---------------|------------------------------------------------------------------------------|
| nfs_client_access_cache          | 5             | NFS access results caching, according to `nfs_access_cache` in `rc.conf(5)`. |
| nfs_client_bufpackets            | 64            | Value of the `nfs_bufpackets` `rc.conf(5)` setting.                          |
| nfs_client_extra_kernel_settings | []            | See `nfs_client_extra_kernel_settings` below.                                |

Dependencies
------------

* Global variables provided by the consumer of the role:
  * `nfs_client_shares`: List of dictionaries of NFS shares to mount, with attributes:
    * `host`: Host that exports the target NFS share.
    * `src`: Path of the target NFS share within the host that exports it.
    * `path`: Path where the target NFS share should be mounted on the client.
    * `opts`: Mount options for the target NFS share.
  * `nfs_client_extra_kernel_settings`: List of dictionaries of extra kernel runtime settings to configure via `sysctl(8)`, with attributes:
    * `key`: Name of the runtime kernel tunable to set via `sysctl(8)`.
    * `value`: Value for `key` to set via the corresponding `sysctl(8)` invocation.
    * `description`: Optional description of the effect of setting `key` to `value` via `sysctl(8)`.

Example Ansible Configuration
-----------------------------

```ini
[privilege_escalation]
become = true
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
    - { role: ap_labs.freebsd_provisioning.bootstrap, tags: [bootstrap] }

- name: Configure NFS shares
  hosts: all
  roles:
    - { role: ap_labs.freebsd_provisioning.nfs_client, tags: [nfs_client] }
```

Execution
---------

Run the orchestration playbook against your target inventory environment:

```sh
ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags nfs_client playbook.yml
```
