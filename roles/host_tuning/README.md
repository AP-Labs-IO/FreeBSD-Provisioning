Host Tuning
===========

Tune host low-level performance and power parameters.

Requirements
------------

* An already bootstrapped FreeBSD environment, i.e.:
  * With a Python runtime.
  * With key-based SSH access.
  * A functional `become` setup.

The last set of requirements can be easily met by running the `ap_labs.freebsd_provisioning.bootstrap` role as a precursor to this one.

Role Variables
--------------

| Variable                                        | Default value | Description                                                                                                                                                   |
|-------------------------------------------------|---------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| host_tuning_installation_directory              | libexec       | Installation directory.                                                                                                                                       |
| host_tuning_namespace                           | ap-labs       | Installation subdirectory.                                                                                                                                    |
| host_tuning_performance_cx_lowest               | Cmax          | CPU AC power idle state.                                                                                                                                      |
| host_tuning_economy_cx_lowest                   | Cmax          | CPU non-AC power idle state.                                                                                                                                  |
| host_tuning_cpu_package_level_power_control     | 0             | Whether CPU power settings are controlled at the CPU package level or not, according to the `machdep.hwpstate_pkg_ctrl` `sysctl(8)`.                          |
| host_tuning_storage_pm_enabled                  | true          | Whether storage devices power management should be configured.                                                                                                |
| host_tuning_storage_pm_ata_devices              | []            | See `host_tuning_storage_pm_ata_devices` below.                                                                                                               |
| host_tuning_storage_pm_ata_devices_idle_seconds | 0             | Default idle seconds for storage devices in `host_tuning_storage_pm_ata_devices` that don't customize their own idle parameter, according to `camcontrol(8)`. |

As a first step, the role queries the target node's "local base", i.e. the result of `sysctl -n user.localbase`, and uses that plus the `host_tuning_installation_directory` & `host_tuning_namespace` variables above, and the role's name, to construct the full path where scripts will be installed.

In a default setup, this construction results in an installation path of `/usr/local/libexec/ap-labs/host_tuning`.

Dependencies
------------

* Global variables provided by the consumer of the role:
  * `host_tuning_storage_pm_ata_devices`: Array of dictionaries describing the ATA storage devices for which power management is desired, with attributes:
    * `node`: String listing the node name of the target disk to configure, e.g. `ada0`.
    * `idle_seconds`: Optional integer after which the corresponding ATA device should be put into idle state, according to `camcontrol(8)`. Defaults to the value of `host_tuning_storage_pm_ata_devices_idle_seconds` if missing.
    * `apm_level`: Optional integer for the corresponding device's `apm`, i.e. "Advanced Power Management" level, according to `camcontrol(8)`, defaulting to a disabled `apm` when missing.
    * `aam_level`: Optional integer for the corresponding device's `aam`, i.e. "Automatic Acoustic Managemet" level, according to `camcontrol(8)`, defaulting to a disabled `aam` when missing. The special string value of `skip` fully skips attempting to set the `aam` to any value for a device that may not support the feature.

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

- name: ...
  hosts: all
  roles:
    - { role: ap_labs.freebsd_provisioning.host_tuning, tags: [host_tuning] }
```

Execution
---------

Run the orchestration playbook against your target inventory environment:

```sh
ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags host_tuning playbook.yml
```
