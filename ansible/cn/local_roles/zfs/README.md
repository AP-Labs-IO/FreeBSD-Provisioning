ZFS
===

Configure FreeBSD nodes with ZFS services.

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

| Variable                                     | Default value    | Description                                   |
|----------------------------------------------|------------------|-----------------------------------------------|
| zfs_encryption_keys_directory                | `/root/.zfskeys` | Directory where ZFS encryption keys are kept. |
| zfs_encryption_datasets                      | []               | See `zfs_encryption_datasets` below.          |
| zfs_pools_scrub_schedules                    | []               | See `zfs_pools_scrub_schedules` below.        |

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `zfs_encryption_datasets`: List of dictionaries describing the encrypted ZFS datasets and their encryption keys, with attributes:
    * `dataset`: The full path of the ZFS dataset.
    * `key`: The encryption key for the ZFS dataset.
  * `zfs_pools_scrub_schedules`: A list of dictionaries describing the the ZFS pools to scrub and their corresponding cron schedules, with attributes:
    * `pool`: The name of the ZFS pool.
    * Cron calendar options compatible with Ansible's `ansible.builtin.cron` module.

Example Playbook
----------------

```yaml
---
- name: Bootstrap Node
  hosts: all:!replication
  become: false
  gather_facts: false
  vars: { ansible_user: root }
  roles:
    - { role: bootstrap, tags: [bootstrap] }

- name: Configure ZFS Services
  hosts: all:!replication
  become: true
  roles:
    - { role: zfs, tags: [zfs] }

- name: Configure ZFS replication targets
  hosts: replication
  become: true
  tasks:
    - name: Import snapshotting & replication common tasks
      ansible.builtin.import_role:
        name: zfs
        tasks_from: zrepl_common.yml

    - name: Import snapshotting & replication target tasks
      ansible.builtin.import_role:
        name: zfs
        tasks_from: zrepl_target.yml
  tags: [zfs]
```

Execution
---------

Run the master orchestration playbook against your target inventory environment:

```sh
ansible-playbook -v --diff -i inventory/$env.yml -i inventory/replication.yml --tags bootstrap --tags zfs playbook.yml
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
