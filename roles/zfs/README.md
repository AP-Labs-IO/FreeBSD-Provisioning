ZFS
===

Configure FreeBSD nodes with [ZFS](https://openzfs.org/wiki/Main_Page) services.

Requirements
------------

* An already bootstrapped FreeBSD environment, i.e.:
  * With a Python runtime.
  * With key-based SSH access.
  * A functional `become` setup.
* The [`net-im/py-apprise`](https://github.com/caronc/apprise) tool with a working configuration.

The bootstrap set of requirements can be easily met by running the [`ap_labs.freebsd_provisioning.bootstrap`](../bootstrap/README.md) role as a precursor to this one, while installation and configuration for the `net-im/py-apprise` tool can be accomplished by running the [`ap_labs.freebsd_provisioning.monitoring`](../monitoring/README.md) role.

Role Variables
--------------

| Variable                                     | Default value                              | Description                                                                      |
|----------------------------------------------|--------------------------------------------|----------------------------------------------------------------------------------|
| zfs_sensitive_logging_disabled               | true                                       | Boolean that dictates whether task output considered sensitive is logged or not. |
| zfs_installation_directory                   | libexec                                    | Installation directory.                                                          |
| zfs_namespace                                | ap-labs                                    | Installation subdirectory.                                                       |
| zfs_data_pools                               | []                                         | List of data pools names to import.                                              |
| zfs_encryption_keys_directory                | /etc/zfs/keys                              | Directory where ZFS encryption keys are kept.                                    |
| zfs_encryption_datasets                      | []                                         | See `zfs_encryption_datasets` below.                                             |
| zfs_pools_scrub_schedules                    | []                                         | See `zfs_pools_scrub_schedules` below.                                           |
| zfs_pools_capacity_monitoring_schedule       | minute: 0                                  | See `zfs_pools_capacity_monitoring_schedule` below.                              |
| zfs_replication_target_port                  | 22                                         | SSH port for the `zfs_replication_target_host`.                                  |
| zfs_snapshotting_schedules                   | []                                         | See `zfs_snapshotting_schedules` below.                                          |
| zfs_replication_monitoring_schedule          | minute: "*/15"                             | See `zfs_replication_monitoring_schedule` below.                                 |
| zfs_zpool_capacity_thresholds                | See `zfs_zpool_capacity_thresholds` below. | See `zfs_zpool_capacity_thresholds` below.                                       |
| zfs_vdev_async_write_max_active              | 5                                          | Maximum async write I/O operations per vdev.                                     |
| zfs_vdev_async_write_min_active              | 1                                          | Minimum async write I/O operations per vdev.                                     |
| zfs_lowmem_callback_period                   | 0                                          | Low memory callback period.                                                      |
| zfs_extra_loader_settings                    | []                                         | See `zfs_extra_loader_settings` below.                                           |
| zfs_services_memory_allocation               | 0                                          | See `zfs_services_memory_allocation` below.                                      |
| zfs_host_memory_reservation                  | 0                                          | See `zfs_host_memory_reservation` below.                                         |
| zfs_arc_min_multiplier                       | 0.25                                       | See `zfs_arc_min_multiplier` below.                                              |
| zfs_file_timestamp_precision                 | 3                                          | File timestamp precision, according to `sysctl -d vfs.timestamp_precision`.      |
| zfs_extra_kernel_settings                    | []                                         | See `zfs_extra_kernel_settings`  below.                                          |

As a first step, the role queries the target node's "local base", i.e. the result of `sysctl -n user.localbase`, and uses that plus the `zfs_installation_directory` & `zfs_namespace` variables above, and the role's name, to construct the full path where scripts will be installed.

In a default setup, this construction results in an installation path of `/usr/local/libexec/ap-labs/zfs`.

At present, zrepl configuration installed by this role is limited to a single replication target host, and the replication job created on the latter is hardcoded to a type of `sync` and a serve type of `stdinserver`. These limitations will be progressively lifted to support multiple replication targets and to allow for more flexible customizations of the receiver replication job.

Dependencies
------------

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
    * `group`: The user's main group.
    * `gid`: Optional GID of the group, defaulting to the next available GID.
  * `zfs_replication_target_host`: FQDN of the host to target for replication.
  * `zfs_replication_target_dataset`: Full ZFS dataset name on the `zfs_replication_target_host` that will be receiving the replicated snapshots.
  * `zfs_snapshotting_schedules`: List of dictionaries of zrepl snapshotting and replication schedules, with attributes:
    * `name`: Name of the schedule, compatible with zrepl's schedule naming requirements.
    * `type`: Optional type of zrepl schedule, defaulting to `push`.
    * `connect_raw`: Optional arbitrary YAML object defining the desired zrepl `connection` block for the schedule. If not defined, the connection defaults to:

      ```yaml
        type: ssh+stdinserver
        host: {{ zfs_replication_target_host }}
        port: {{ zfs_replication_target_port }}
        user: {{ zfs_replication_user.name }}
        identity_file: "/home/{{ zfs_replication_user.name }}/.ssh/{{ zfs_replication_keyname }}"
        options:
          - StrictHostKeyChecking=yes
      ```

    * `datasets`: List of datasets to include in the schedule.
    * `snapshotting`: Optional type of zrepl snapshotting to be performed by the schedule, defaulting to `periodic`.
    * `prefix`: Optional string prefix for the snapshot names, defaulting to `{{ name }}_`.
    * `interval`: Snapshotting interval for the schedule, compatible with zrepl's interval requirements.
    * `send`: Optional dictionary describing the send options for the schedule, according to zrepl's requirements. If omitted, it defaults to:

      ```yaml
        send_properties: true
      ```

    * `pruning`: Dictionary describing the snapshots pruning policy to be applied to the schedule, with attributes:
      * `sender_raw`: Optional arbitrary YAML object or list fully describing a custom "sender" pruning policy, compatible with zrepl's pruning requirements.
      * `sender_grid`: zrepl-compatible "sender" pruning grid, mandatory only if `sender_raw` is not defined.
      * `receiver_raw`: Optional arbitrary YAML object or list fully describing a custom "receiver" pruning policy, compatible with zrepl's pruning requirements.
      * `receiver_grid`: zrepl-compatible "receiver" pruning grid, mandatory only if `receiver_raw` is not defined.
  * `zfs_extra_loader_settings`: List of dictionaries of extra `loader(8)` settings to configure, with attributes:
    * `key`: Name of the boot-time ZFS setting to set in `/boot/loader.conf` via `sysctl(8)`.
    * `value`: Value for `key` to set via the corresponding `sysctl(8)` invocation.
    * `description`: Optional description of the effect of setting `key` to `value` via `sysctl(8)`.
  * `zfs_services_memory_allocation`: Amount of memory in GiB consumed by hosted services to be exclude from the ARC, defaulting to `0`. See `zfs_host_memory_reservation` below for further explanations.
  * `zfs_host_memory_reservation`: Amount of memory in GiB to reserve for miscellaneous host operations and to be excluded from the ARC, defaulting to `0`. If both this variable and `zfs_services_memory_allocation` are `0`, the corresponding `vfs.zfs.arc.max` & `vfs.zfs.arc.min` `sysctl(8)` settings are left at their corresponding defaults (`0` in each case), which enables OpenZFS' dynamic ARC management.
  * `zfs_arc_min_multiplier`: Decimal, in the range from `0` to `1`, of the resulting `vfs.zfs.arc.max` `sysctl(8)` setting, i.e. `host total memory - zfs_services_memory_allocation - zfs_host_memory_reservation`, used to compute the amount of memory to assign to `vfs.zfs.arc.min`. This variable has no effect if both `zfs_services_memory_allocation` & `zfs_host_memory_reservation` are `0`.
  * `zfs_extra_kernel_settings`: List of dictionaries of extra kernel runtime settings to configure via `sysctl(8)`, with attributes:
    * `key`: Name of the runtime ZFS setting to set via `sysctl(8)`.
    * `value`: Value for `key` to set via the corresponding `sysctl(8)` invocation.
    * `description`: Optional description of the effect of setting `key` to `value` via `sysctl(8)`.
* A file holding all of the replication target hosts SSH public keys at `files/replication/known_hosts` path.

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
  hosts: all:!replication
  become: false
  gather_facts: false
  vars: { ansible_user: root }
  roles:
    - { role: ap_labs.freebsd_provisioning.bootstrap, tags: [bootstrap] }

- name: Configure Monitoring
  hosts: all:!replication
  roles:
    - { role: ap_labs.freebsd_provisioning.monitoring, tags: [monitoring] }

- name: Configure ZFS Services
  hosts: all:!replication
  roles:
    - { role: ap_labs.freebsd_provisioning.zfs, tags: [zfs] }

- name: Configure ZFS replication targets
  hosts: replication
  tasks:
    - name: Import snapshotting & replication common tasks
      ansible.builtin.import_role:
        name: ap_labs.freebsd_provisioning.zfs
        tasks_from: zrepl_common.yml

    - name: Import snapshotting & replication target tasks
      ansible.builtin.import_role:
        name: ap_labs.freebsd_provisioning.zfs
        tasks_from: zrepl_target.yml
  tags: [zfs]
```

Execution
---------

Run the orchestration playbook against your target inventory environment:

```sh
ansible-playbook -v --diff -i inventory/$env.yml -i inventory/replication.yml --tags bootstrap --tags monitoring --tags zfs playbook.yml
```
