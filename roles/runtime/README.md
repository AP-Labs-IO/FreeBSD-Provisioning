Runtime
=======

Configure runtime kernel state & settings, as documented by `sysctl(8)`.

Requirements
------------

* An already bootstrapped FreeBSD environment, i.e.:
  * With a Python runtime.
  * With key-based SSH access.
  * A functional `become` setup.

The last set of requirements can be easily met by running the [`ap_labs.freebsd_provisioning.bootstrap`](../bootstrap/README.md) role as a precursor to this one.

Role Variables
--------------

| Variable                      |  Default value    | Description                                                                            |
|-------------------------------|-------------------|----------------------------------------------------------------------------------------|
| runtime_somaxconn_size        | 2048              | Max pending socket connections queue size, according to `sysctl kern.ipc.somaxconn`.   |
| runtime_kq_calloutmax         | 150000            | Max number of callouts allocated for kqueue, according to `sysctl kern.kq_calloutmax`. |
| runtime_extra_kernel_settings | []                | See `runtime_extra_kernel_settings` below.                                             |

Dependencies
------------

* Global variables provided by the consumer of the role:
  * `runtime_mac_do_rules`: String with the desired `mac_do(4)` configuration.
  * `runtime_extra_kernel_settings`: List of dictionaries of extra kernel runtime settings to configure via `sysctl(8)`, with attributes:
    * `key`: Name of the runtime kernel tunable to set via `sysctl(8)`.
    * `value`: Value for `key` to set via the corresponding `sysctl(8)` invocation.
    * `description`: Optional description of the effect of setting `key` to `value` via `sysctl(8)`.

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

- name: Configure runtime state
  hosts: all
  roles:
    - { role: ap_labs.freebsd_provisioning.runtime, tags: [runtime] }
```

Execution
---------

Run the orchestration playbook against your target inventory environment:

```sh
ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags runtime playbook.yml
```
