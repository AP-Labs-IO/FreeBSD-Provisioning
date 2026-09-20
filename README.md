Runtime
=======

Configure runtime kernel state & settings, as documented by `sysctl(8)`.

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

| Variable               |  Default value    | Description                         |
|------------------------|-------------------|-------------------------------------|
| runtime_extra_settings | []                | See `runtime_extra_settings` below. |

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `runtime_mac_do_rules`: String with the desired `mac_do(4)` configuration.
  * `runtime_extra_settings`: List of dictionaries with attributes:
    * `key`: Name of the runtime kernel tunable to set via `sysctl(8)`.
    * `value`: Value of `key` to set via the corresponding `sysctl(8)` invocation.
    * `description`: Description of the effect of setting `key` to `value` via `sysctl(8)`.

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

- name: Configure runtime state
  hosts: all
  become: true
  roles:
    - { role: runtime, tags: [runtime }
```

Execution
---------

Run the master orchestration playbook against your target inventory environment:

```sh
ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags runtime playbook.yml
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
