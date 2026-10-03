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
* The `net-im/py-apprise` tool with a working configuration.

The bootstrap set of requirements can be easily met by running the `ap_labs.bootstrap` role as a precursor to this one, while installation and configuration for the `net-im/py-apprise` tool can be accomplished by running the local `monitoring` role.

Role Variables
--------------

| Variable                                     | Default value    | Description                                                                |
|----------------------------------------------|------------------|----------------------------------------------------------------------------|
| zfs_installation_directory                   | libexec          | Installation directory.                                                    |
| zfs_namespace                                | ap-labs          | Installation subdirectory.                                                 |
| zfs_data_pools                               | []               | List of data pools names to import.                                        |
| zfs_encryption_keys_directory                | `/root/.zfskeys` | Directory where ZFS encryption keys are kept.                              |
| zfs_encryption_datasets                      | []               | See `zfs_encryption_datasets` below.                                       |
| zfs_pools_scrub_schedules                    | []               | See `zfs_pools_scrub_schedules` below.                                     |
| zfs_pools_capacity_monitoring_schedule       | minute: 0        | See `zfs_pools_capacity_monitoring_schedule` below.                        |
| zfs_replication_monitoring_schedule          | minute: "*/15"   | See `zfs_replication_monitoring_schedule` below.                           |
| zfs_zpool_capacity_thresholds                | See `zfs_zpool_capacity_thresholds` below. | See `zfs_zpool_capacity_thresholds` below.     |
| zfs_vdev_async_write_max_active              | 5                | Maximum async write I/O operations per vdev.                               |
| zfs_vdev_async_write_min_active              | 1                | Minimum async write I/O operations per vdev.                               |
| zfs_lowmem_callback_period                   | 0                | Low memory callback period.                                                |
| zfs_extra_boot_settings                      | []               | See `zfs_extra_boot_settings` below.                                       |
| zfs_services_memory_allocation               | 0                | See `zfs_services_memory_allocation` below.                                |
| zfs_host_memory_reservation                  | 0                | See `zfs_host_memory_reservation` below.                                   |
| zfs_arc_min_multiplier                       | 0.25             | See `zfs_arc_min_multiplier` below.                                        |
| zfs_file_timestamp_precision                 | 3                | File timestamp precision, according to `sysctl -d vfs.timestamp_precision` |
| zfs_extra_runtime_settings                   | []               | See `zfs_extra_runtime_settings` below.                                    |

As a first step, the role queries the target node's "local base", i.e. the result of `sysctl -n user.localbase`, and uses that plus the `zfs_installation_directory` & `zfs_namespace` variables above, and the role's name, to construct the full path where scripts will be installed.

In a default setup, this construction results in an installation path of `/usr/local/libexec/ap-labs/zfs`.

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `zfs_encryption_datasets`: List of dictionaries describing the encrypted ZFS datasets and their encryption keys, with attributes:
    * `dataset`: The full path of the ZFS dataset.
    * `key`: The encryption key for the ZFS dataset.
  * `zfs_pools_scrub_schedules`: A list of dictionaries describing the ZFS pools to scrub and their corresponding cron schedules, with attributes:
    * `pool`: The name of the ZFS pool.
    * Dictionary accepting `minute`, `hour`, `day`, `weekday`, and `special_time` attributes as described by the `ansible-doc` documentation for the `ansible.builtin.cron` module.
  * `zfs_pools_capacity_monitoring_schedule`: Dictionary describing the cron schedule for the pools capacity monitoring job, accepting `minute`, `hour`, `day`, `weekday`, and `special_time` attributes as described by the `ansible-doc` documentation for the `ansible.builtin.cron` module.
  * `zfs_replication_monitoring_schedule`: Dictionary describing the cron schedule for the replication monitoring job, accepting `minute`, `hour`, `day`, `weekday`, and `special_time` attributes as described by the `ansible-doc` documentation for the `ansible.builtin.cron` module.
  * `zfs_zpool_capacity_thresholds`: Dictionary of zpool capacity thresholds at which to issue corresponding warnings, with mandatory attributes:
    * `notice`: Defaults to 70%.
    * `warning`: Defaults to 80%.
    * `critical`: Defaults to 90%.
  * `zfs_replication_user`: Dictionary describing the user who will perform replication, with attributes:
    * `name`: The user's username.
    * `uid`: Optional UID of the user, defaulting to the next available UID.
    * `name`: The user's main group.
    * `gid`: Optional GID of the group, defaulting to the next available GID.
  * `zfs_replication_target_host`: FQDN of the host to target for replication. This role expects a file by the name of `known_hosts_{{ zfs_replication_target_host }}` to be present at the root of the project's `files` directory, holding the replication target host's SSH public keys.
  * `zfs_replication_target_dataset`: Full path of the ZFS dataset on the `zfs_replication_target_host` that will be receiving replicated snapshots.
  * `zfs_hourly_snapshots_datasets`: List of ZFS datasets to include in the hourly snapshotting and replication schedule.
  * `zfs_nightly_snapshots_datasets`: List of ZFS datasets to include in the nightly snapshotting and replication schedule.
  * `zfs_extra_boot_settings`: List of dictionaries of extra boot-time ZFS tuning settings, with attributes:
    * `key`: Name of the boot-time ZFS setting to set in `/boot/loader.conf` via `sysctl(8)`.
    * `value`: Value for `key` to set via the corresponding `sysctl(8)` invocation.
    * `description`: Optional description of the effect of setting `key` to `value` via `sysctl(8)`.
  * `zfs_services_memory_allocation`: Amount of memory in GiB consumed by hosted services to be exclude from the ARC, defaulting to `0`. See `zfs_host_memory_reservation` below for further explanations.
  * `zfs_host_memory_reservation`: Amount of memory in GiB to reserve for miscellaneous host operations and to be excluded from the ARC, defaulting to `0`. If both this variable and `zfs_services_memory_allocation` are `0`, the corresponding `vfs.zfs.arc.max` & `vfs.zfs.arc.min` `sysctl(8)` settings are left at their corresponding defaults (`0` in each case), which enables OpenZFS' dynamic ARC management.
  * `zfs_arc_min_multiplier`: Fraction, in the range from `0` to `1`, of the resulting `vfs.zfs.arc.max` `sysctl(8)` setting, i.e. `host total memory - zfs_services_memory_allocation - zfs_host_memory_reservation`, used to compute the amount of memory to assign to `vfs.zfs.arc.min`. This variable has no effect if both `zfs_host_memory_reservation` & `zfs_host_memory_reservation` are `0`.
  * `zfs_extra_runtime_settings`: List of dictionaries of extra runtime ZFS tuning settings, with attributes:
    * `key`: Name of the runtime ZFS setting to set via `sysctl(8)`.
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
```

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

- name: Configure Monitoring
  hosts: all:!replication
  roles:
    - { role: monitoring, tags: [monitoring] }

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
-> ansible-galaxy role install -r requirements.yml -f -p ./roles
-> ansible-playbook -v --diff -i inventory/$env.yml -i inventory/replication.yml --tags bootstrap --tags monitoring --tags zfs playbook.yml
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
