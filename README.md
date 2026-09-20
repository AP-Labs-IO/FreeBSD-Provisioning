Boot
====

Configure boot-time settings, such as kernel modules and tunables, as documented by `loader(8)` & `rc.conf(5)`.

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

| Variable             | Default value     | Description                                |
|----------------------|-------------------|--------------------------------------------|
| boot_kernel_modules  | []                | See `boot_kernel_modules` below.           |
| boot_loader_settings | []                | See `boot_loader_settings` below.          |
| boot_rc_settings     | []                | See `boot_rc_settings` below.              |
| boot_enable_moused   | true              | Boolean toggle to enable the mouse daemon. |
| boot_efi_partition   | /dev/gpt/efiboot0 | EFI partition.                             |

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `boot_kernel_modules`: List of strings with the names of the kernel modules to load.
  * `boot_loader_settings`: List of dictionaries with attributes:
    * `key`: Name of the boot-time kernel tunable to set via `sysctl(8)`.
    * `value`: Value of `key` to set via the corresponding `sysctl(8)` invocation.
    * `description`: Description of the effect of setting `key` to `value` via `sysctl(8)`.
  * `boot_rc_settings`: List of dictionaries of `rc.conf(5)` settings to configure via `sysrc(8)`, with attributes:
    * `key`: Name of the `rc.conf(5)` setting.
    * `value`: Desired value for the corresponding `key`.
  * `boot_swap_devices`: List of strings, each expected to point to the full path of a swap device to activate.

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
ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags boot playbook.yml
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
