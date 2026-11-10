NFS Server
==========

Configure an NFSv4 server, defaulting to a TCP-only transport, though configurable, and relying exclusively on the numeric "owner_names" mechanism for ownership information synchronization, via the `vfs.nfsd.enable_stringtouid` & `vfs.nfs.enable_uidtostring` sysctl's, rather falling back on the `nfsuserd(8)` daemon.

Requirements
------------

* An already bootstrapped FreeBSD environment, i.e.:
  * With a Python runtime.
  * With key-based SSH access.
  * A functional `become` setup.

The last set of requirements can be easily met by running the `ap_labs.freebsd_provisioning.bootstrap` role as a precursor to this one.

Role Variables
--------------

| Variable                          | Default value      | Description                                                                                       |
|-----------------------------------|--------------------|---------------------------------------------------------------------------------------------------|
| nfs_server_fha_write_locality     | 0                  | Enable FHA write locality, according to `sysctl vfs.nfsd.fha.write`.                              |
| nfs_server_extra_loader_settings  | []                 | See `nfs_server_extra_loader_settings` below.                                                     |
| nfs_server_nfsd_flags             | -t                 | `nfsd(8)` flags.                                                                                  |
| nfs_server_exports_file_path      | nfs_server/exports | Path within the project's `files` directory to the `exports(5)` file to install.                  |
| nfs_server_extra_kernel_settings  | []                 | See `nfs_server_extra_kernel_settings` below.                                                     |

Dependencies
------------

* Global variables provided by the consumer of the role:
  * `nfs_server_extra_loader_settings`: List of dictionaries of extra `loader(8)` settings to configure, with attributes:
    * `key`: Name of the loader setting to set via `sysctl(8)`.
    * `value`: Value for `key` to set via the corresponding `sysctl(8)` invocation.
    * `description`: Optional description of the effect of setting `key` to `value` via `sysctl(8)`.
  * `nfs_server_extra_kernel_settings`: List of dictionaries of extra kernel runtime settings to configure via `sysctl(8)`, with attributes:
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

- name: Configure NFSv4 Server
  hosts: all:!replication
  roles:
    - { role: ap_labs.freebsd_provisioning.nfs_server, tags: [nfs_server] }
```

Execution
---------

Run the orchestration playbook against your target inventory environment:

```sh
ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags nfs_server playbook.yml
```
