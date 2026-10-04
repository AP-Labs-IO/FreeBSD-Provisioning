Boot
====

Configure boot-time settings, such as kernel modules, loader settings, and tunables, as documented by `loader(8)` & `rc.conf(5)`.

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

| Variable               | Default value     | Description                                |
|------------------------|-------------------|--------------------------------------------|
| boot_kernel_modules    | []                | See `boot_kernel_modules` below.           |
| boot_loader_settings   | []                | See `boot_loader_settings` below.          |
| boot_extra_rc_settings | []                | See `boot_extra_rc_settings` below.        |
| boot_moused_enabled    | true              | Boolean toggle to enable the mouse daemon. |
| boot_efi_partition     | /dev/gpt/efiboot0 | EFI partition.                             |

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `boot_kernel_modules`: List of strings with the names of the kernel modules to load.
  * `boot_loader_settings`: List of dictionaries with attributes:
    * `key`: Name of the loader setting to set via `sysctl(8)`.
    * `value`: Value for `key` to set via the corresponding `sysctl(8)` invocation.
    * `description`: Optional description of the effect of setting `key` to `value` via `sysctl(8)`.
  * `boot_keymap`: Desired keyboard map.
  * `boot_timezone`: Desired timezone.
  * `boot_extra_rc_settings`: List of dictionaries of early `rc.conf(5)` settings to configure via `sysrc(8)`, with attributes:
    * `key`: Name of the `rc.conf(5)` setting.
    * `value`: Desired value for the corresponding `key`.
  * `boot_swap_devices`: List of strings, each expected to point to the full path of a swap device to activate.

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
  src: git+ssh://git@gitlab.lan/ap-labs/ansible-roles/boot.git
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

- name: Configure Early Boot Environment
  hosts: all
  become: true
  roles:
    - { role: boot, tags: [boot] }
```

Execution
---------

Run the master orchestration playbook against your target inventory environment:

```sh
-> ansible-galaxy role install -r requirements.yml -p ./roles
-> ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags boot playbook.yml
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
