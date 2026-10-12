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

The last set of requirements can be easily met by running the `ap_labs.bootstrap` role as a precursor to this one.

Role Variables
--------------

| Variable                      |  Default value    | Description                                |
|-------------------------------|-------------------|--------------------------------------------|
| runtime_somaxconn_size        | 2048              | Max pending socket connections queue size, according to `sysctl kern.ipc.somaxconn`. |
| runtime_extra_kernel_settings | []                | See `runtime_extra_kernel_settings` below. |

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `runtime_mac_do_rules`: String with the desired `mac_do(4)` configuration.
  * `runtime_extra_kernel_settings`: List of dictionaries with attributes:
    * `key`: Name of the runtime kernel tunable to set via `sysctl(8)`.
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

- name: runtime
  src: git+ssh://git@gitlab.lan/ap-labs/ansible-roles/runtime.git
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

- name: Configure runtime state
  hosts: all
  roles:
    - { role: runtime, tags: [runtime }
```

Execution
---------

Run the master orchestration playbook against your target inventory environment:

```sh
-> ansible-galaxy role install -r requirements.yml -p ./roles
-> ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags runtime playbook.yml
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
