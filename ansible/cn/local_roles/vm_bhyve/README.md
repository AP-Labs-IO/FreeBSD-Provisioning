VM Bhyve
========

Configure FreeBSD nodes to host vm-bhyve(8) managed VMs.

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

| Variable                      | Default value | Description                                                |
|-------------------------------|---------------|------------------------------------------------------------|
| vm_bhyve_passthrough_devices  | []            | See `vm_bhyve_passthrough_devices` below.                  |
| vm_bhyve_host_checks_disabled | false         | Instruct the `vm(8)` tool to bypass system support checks. |
| vm_bhyve_startup_vms          | []            | See `vm_bhyve_startup_vms` below.                          |
| vm_bhyve_startup_delay        | 5             | Delay in seconds between each VM to autostart              |

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `vm_bhyve_passthrough_devices`: List of PCI devices to reserve for PCI passthrough via the `pptdevs` `loader.conf(5)` variable, in standard `bus/slot/function` notation.
  * `vm_bhyve_startup_vms`: List of VMs to autostart up on system boot.

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

- name: Configure vm-bhyve
  hosts: all
  become: true
  roles:
    - { role: vm_bhyve, tags: [vm-bhyve] }
```

Execution
---------

Run the master orchestration playbook against your target inventory environment:

```sh
-> ansible-galaxy role install -r requirements.yml -p ./roles
-> ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags vm-bhyve playbook.yml
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
