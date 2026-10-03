Monitoring
==========

Configure monitoring on a FreeBSD node.

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

| Variable                                      | Default value                                       | Description                                                |
|-----------------------------------------------|-----------------------------------------------------|------------------------------------------------------------|
| monitoring_installation_directory             | libexec                                             | Installation directory.                                    |
| monitoring_namespace                          | ap-labs                                             | Installation subdirectory.                                 |
| monitoring_watchdogd_flags                    | --pretimeout 10 --pretimeout-action log,printf      | See `monitoring_watchdogd_flags` below.                    |
| monitoring_smartd_poll_interval               | 300                                                 | See `monitoring_smartd_poll_interval` below.               |
| monitoring_smartd_alert_recipient             | root                                                | See `monitoring_smartd_alert_recipient` below.             |
| monitoring_smartd_drivedb_update_schedule     | special_time: weekly                                | See `monitoring_smartd_drivedb_update_schedule` below.     |
| monitoring_nvme_controllers                   | []                                                  | See `monitoring_nvme_controllers` below.                   |
| monitoring_nvme_info_temp                     | 65                                                  | See `monitoring_nvme_info_temp` below.                     |
| monitoring_nvme_critic_temp                   | 70                                                  | See `monitoring_nvme_critic_temp` below.                   |
| monitoring_disks                              | []                                                  | See `monitoring_disks` below.                              |
| monitoring_disk_info_temp                     | 45                                                  | See `monitoring_disk_info_temp` below.                     |
| monitoring_disk_critic_temp                   | 50                                                  | See `monitoring_disk_critic_temp` below.                   |
| monitoring_ipmi_monitoring_schedule           | special_time: daily                                 | See `monitoring_ipmi_monitoring_schedule` below.           |
| monitoring_collectd_interval                  | 10                                                  | See `monitoring_collectd_interval` below.                  |
| monitoring_collectd_ignore_interfaces         | See `monitoring_collectd_ignore_interfaces` below.  | See `monitoring_collectd_ignore_interfaces` below.         |
| monitoring_collectd_ignore_mountpoints        | See `monitoring_collectd_ignore_mountpoints` below. | See `monitoring_collectd_ignore_mountpoints` below.        |
| monitoring_collectd_graphite_port             | 2003                                                | See `monitoring_collectd_graphite_port` below.             |
| monitoring_collectd_graphite_prefix           | See `monitoring_collectd_graphite_prefix` below.    | See `monitoring_collectd_graphite_prefix` below.           |
| monitoring_alert_targets                      | []                                                  | See `monitoring_alert_targets` below.                      |
| monitoring_jails                              | ""                                                  | Space-separated list of jails to monitor.                  |
| monitoring_extra_services                     | ""                                                  | Space-separated list of extra services to monitor.         |
| monitoring_base_services_monitoring_schedule  | minute: "*/5"                                       | See `monitoring_base_services_monitoring_schedule` below.  |
| monitoring_jails_monitoring_schedule          | minute: "*/5"                                       | See `monitoring_jails_monitoring_schedule` below.          |
| monitoring_extra_services_monitoring_schedule | minute: "*/5"                                       | See `monitoring_extra_services_monitoring_schedule` below. |

As a first step, the role queries the target node's "local base", i.e. the result of `sysctl -n user.localbase`, and uses that plus the `monitoring_installation_directory` & `monitoring_namespace` variables above, and the role's name, to construct the full path where scripts will be installed.

In a default setup, this construction results in an installation path of `/usr/local/libexec/ap-labs/monitoring`.

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `monitoring_watchdogd_flags`: String listing the launch flags for the `watchdogd(8)` service.
  * `monitoring_smartd_poll_interval`: Interger listing the `smartd(8)` disk polling interval.
  * `monitoring_smartd_alert_recipient`: String listing the `smartd(8)` alerts email address recipient.
  * `monitoring_smartd_drivedb_update_schedule`: Dictionary describing the cron schedule for the execution of the smartd drivedb update job, accepting `minute`, `hour`, `day`, `weekday`, and `special_time` attributes as described by the `ansible-doc` documentation for the `ansible.builtin.cron` module.
  * `monitoring_nvme_controllers`: List of dictionaries describing the NVME controllers to monitor via `smartd(8)`, with attributes:
    * `node`: String listing the node name of the target NVME controller, e.g. `nvme0`.
    * `info_temp`: Optional integer listing the target NVME controller's `information` temperature threshold, defaulting to the value of the `monitoring_nvme_info_temp` variable.
    * `critic_temp`: Optional integer listing the target NVME controller's `critical` temperature threshold, defaulting to the value of the `monitoring_nvme_critic_temp` variable.
  * `monitoring_nvme_info_temp`: The default `information` temperature threshold for NVME controllers.
  * `monitoring_nvme_critic_temp`: The default `critical` temperature threshold for NVME controllers.
  * `monitoring_disks`: List of dictionaries describing the disks to monitor via `smartd(8)`, with attributes:
    * `node`: String listing the node name of the target disk to monitor via `smartd(8)`, e.g. `ada0` or `vtbd1`.
    * `info_temp`: Optional integer listing the target disk's `information` temperature threshold, defaulting to the value of the `monitoring_disk_info_temp` variable.
    * `critic_temp`: Optional integer listing the target disk's `critical` temperature threshold, defaulting to the value of the `monitoring_disk_critic_temp` variable.
  * `monitoring_disk_info_temp`: The default `information` temperature threshold for disks.
  * `monitoring_disk_critic_temp`: The default `critical` temperature threshold for disks.
  * `monitoring_ipmi_monitoring_schedule`: Dictionary describing the cron schedule for the execution of the IPMI monitoring job, accepting `minute`, `hour`, `day`, `weekday`, and `special_time` attributes as described by the `ansible-doc` documentation for the `ansible.builtin.cron` module.
  * `monitoring_collectd_interval`: Integer listing the default `collectd(8)` metrics collection interval.
  * `monitoring_collectd_ignore_interfaces`: List of strings listing the network interfaces to ignore from `collectd(8)` metrics collection, defaulting to:
    * `lo0`
    * `ipfw0`
    * `pflog0`
    * `pfsync0`
    * `plip0`
    * `epair`
    * `bridge`
  * `monitoring_collectd_ignore_mountpoints`: List of strings listing the mountpoints to ignore from `collectd(8)` metrics collection, defaulting to:
    * `/usr/src`
    * `/usr/ports`
    * `/var/run`
  * `monitoring_collectd_graphite_host`: Mandatory string listing the Graphite host where `collectd(8)` metrics are sent.
  * `monitoring_collectd_graphite_port`: Integer listing the Graphite port of the `monitoring_collectd_graphite_host` target.
  * `monitoring_collectd_graphite_prefix`: Graphite metrics prefix, defaulting to the target node's first inventory group, or the literal `standalone` string if the node does not belong to any inventory group.
  * `monitoring_alert_targets`: List of dictionaries describing the Apprise notification targets, with attributes:
    * `url`: String holding any supported Apprise URL.
    * `config`: Optional dictionary with keys and values appropriate for the target Apprise URL.
    * `tags`: List of strings holding the Apprise tags that apply to the target URL.
  * `monitoring_base_services_monitoring_schedule`: Dictionary describing the cron schedule for the execution of the base services monitoring job, accepting `minute`, `hour`, `day`, `weekday`, and `special_time` attributes as described by the `ansible-doc` documentation for the `ansible.builtin.cron` module.
  * `monitoring_jails_monitoring_schedule`: Dictionary describing the cron schedule for the execution of the jails monitoring job, accepting `minute`, `hour`, `day`, `weekday`, and `special_time` attributes as described by the `ansible-doc` documentation for the `ansible.builtin.cron` module.
  * `monitoring_extra_services_monitoring_schedule`: Dictionary describing the cron schedule for the execution of the extra services monitoring job, accepting `minute`, `hour`, `day`, `weekday`, and `special_time` attributes as described by the `ansible-doc` documentation for the `ansible.builtin.cron` module.

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
  hosts: all
  become: false
  gather_facts: false
  vars: { ansible_user: root }
  roles:
    - { role: bootstrap, tags: [bootstrap] }

- name: Configure Monitoring
  hosts: all
  become: true
  roles:
    - { role: monitoring, tags: [monitoring] }
```

Execution
---------

Run the master orchestration playbook against your target inventory environment:

```sh
-> ansible-galaxy role install -r requirements.yml -f -p ./roles
-> ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags monitoring playbook.yml
```

Install the jail monitoring infrastructure once the target jails have been deployed:

```sh
-> ansible-playbook -v --diff -i inventory/$env.yml --tags monitoring-jails playbook.yml
```

Install the extra services monitoring infrastructure once the target services have been deployed:

```sh
-> ansible-playbook -v --diff -i inventory/$env.yml --tags monitoring-extra-services playbook.yml
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
