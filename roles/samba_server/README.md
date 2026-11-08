Samba Server
============

Configure a simple Samba Server, strictly over TCP/IP (i.e. no NetBIOS support), for file sharing purposes only (i.e. without joining a Domain Controller nor acting as one, printing, etc.).

Requirements
------------

* An already bootstrapped FreeBSD environment, i.e.:
  * With a Python runtime.
  * With key-based SSH access.
  * A functional `become` setup.

The last set of requirements can be easily met by running the `ap_labs.freebsd_provisioning.bootstrap` role as a precursor to this one.

Role Variables
--------------

| Variable                                |  Default value  | Description                                                                                       |
|-----------------------------------------|-----------------|---------------------------------------------------------------------------------------------------|
| samba_server_sensitive_logging_disabled | true            | Boolean that dictates whether task output considered sensitive is logged or not.                  |
| samba_server_version                    | 424             | Samba version to install, as expressed by the corresponding FreeBSD package, e.g. `net/samba424`. |
| samba_server_xattr_maxsize              | 2097152         | Maximum size for the "smbd max xattr size" `smb.conf(5)` setting.                                 |
| samba_server_icon                       | Xserve          | Network icon for the Samba server.                                                                |
| samba_server_shares                     | []              | See `samba_serser_shares` below.                                                                  |
| samba_server_users                      | []              | See `samba_server_users` below.                                                                   |

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `samba_server_workgroup`: Samba workgroup.
  * `samba_server_description`: Optional descrition for the Samba server, defaulting to the `%h` substitution.
  * `samba_serser_shares`: List of dictionaries of SMB shares to export, with attributes:
    * `name`: Name of the share.
    * `comment`: Optional comment describing the share, defaulting to the `name` attribute.
    * `path`: Filesystem path to the share.
    * `browsable`: Optional boolean string that determines whether the share is browsable, according to `smb.conf(5)`, defaulting to `"yes"`.
    * `read_only`: Optional boolean string that determines whether the share is read only, according to `smb.conf(5)`, defaulting to `"no"`.
    * `guests`: Optional boolean string that determines whether the share allows guest usage, according to `smb.conf(5)`, defaulting to `"no"`.
    * `time_machine`: Optional boolean that determines whether the share advertises Time Machine support to Mac clients, according to `vfs_fruit(8)`, defaulting to `false`.
    * `shawdow_copies`: Optional dictionary that defines the support offered for shadow copies, according to `smb.conf(5)`. If defined, it should contain attributes:
      * `snapdir`: Optional path to the snapshots directory, defaulting to `.zfs/snapshot`.
      * `format`: The format specification for snapshot names, according to `vfs_shadow_copy2(8)`.
      * `sort`: Optional string controlling the sort order of shadow copies, defaulting to `"desc"`.
      * `localtime`: Optional boolean string that determines whether the snapshot names are in local time or UTC, defaulting to `"yes"`.
  * `samba_server_users`: List of dictionaries of users to record in the Samba database via the `smbpasswd(8)` tool, with attributes:
    * `name`: The user's username.
    * `password`: `ansible-vault` encrypted password for the user.

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
    - { role: ap_labs.freebsd_provisioningbootstrap, tags: [bootstrap] }

- name: Configure Samba Server
  hosts: all
  roles:
    - { role: ap_labs.freebsd_provisioningsamba_server, tags: [samba_server] }
```

Execution
---------

Run the master orchestration playbook against your target inventory environment:

```sh
-> ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags samba_server playbook.yml
```
