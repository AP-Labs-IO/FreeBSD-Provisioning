Host Tuning
===========

Tune host low-level performance and power parameters.

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

| Variable                                        | Default value | Description                                                                                                                                                  |
|-------------------------------------------------|---------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| host_tuning_performance_cx_lowest               | Cmax          | CPU AC power idle state                                                                                                                                      |
| host_tuning_economy_cx_lowest                   | Cmax          | CPU non-AC power idle state                                                                                                                                  |
| host_tuning_cpu_package_level_power_control     | 0             | Whether CPU power settings are controlled at the CPU package level or not, according to the `machdep.hwpstate_pkg_ctrl` `sysctl(8)`.                         |
| host_tuning_storage_pm_enabled                  | true          | Whether storage devices power management should be configured.                                                                                               |
| host_tuning_storage_pm_ata_devices              | []            | See `host_tuning_storage_pm_ata_devices` below.                                                                                                              |
| host_tuning_storage_pm_ata_devices_idle_seconds | 0             | Default idle seconds for storage devices in `host_tuning_storage_pm_ata_devices` that don't customize their own idle parameter, according to `camcontrol(8)` |

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `host_tuning_storage_pm_ata_devices`: Array of dictionaries describing the ATA storage devices for which power management is desired, with attributes:
    * `node`: String listing the node name of the target disk to configure, e.g. `ada0`.
    * `idle_seconds`: Optional integer after which the corresponding ATA device should be put into idle state, according to `camcontrol(8)`. Defaults to the value of `host_tuning_storage_pm_ata_devices_idle_seconds` if missing.
    * `apm_level`: Optional integer for the corresponding device's `apm`, i.e. "Advanced Power Management" level, according to `camcontrol(8)`, defaulting to a disabled `apm` when missing.
    * `aam_level`: Optional integer for the corresponding device's `aam`, i.e. "Automatic Acoustic Managemet" level, according to `camcontrol(8)`, defaulting to a disabled `aam` when missing. The special string value of `skip` fully skips attempting to set the `aam` to any value for a device that may not support the feature.

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

- name: boot
  src: git+ssh://git@gitlab.lan/ap-labs/ansible-roles/host_tuning.git
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

- name: ...
  hosts: all
  become: true
  roles:
    - { role: host_tuning, tags: [host_tuning] }
```

Execution
---------

Run the master orchestration playbook against your target inventory environment:

```sh
-> ansible-galaxy role install -r requirements.yml -f -p ./roles
-> ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags host_tuning playbook.yml
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
