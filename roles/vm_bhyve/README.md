VM Bhyve
========

Configure FreeBSD nodes to host `vm-bhyve(8)` managed VMs.

This role assumes ZFS-based storage, which is a limitation that may be lifted in the future.

Requirements
------------

* An already bootstrapped FreeBSD environment, i.e.:
  * With a Python runtime.
  * With key-based SSH access.
  * A functional `become` setup.

The last set of requirements can be easily met by running the [`ap_labs.freebsd_provisioning.bootstrap`](../bootstrap/README.md) role as a precursor to this one.

Role Variables
--------------

| Variable                             | Default value | Description                                                                      |
|--------------------------------------|---------------|----------------------------------------------------------------------------------|
| vm_bhyve_passthrough_devices         | []            | See `vm_bhyve_passthrough_devices` below.                                        |
| vm_bhyve_host_checks_disabled        | false         | Instruct the `vm(8)` tool to bypass system support checks.                       |
| vm_bhyve_startup_vms                 | []            | See `vm_bhyve_startup_vms` below.                                                |
| vm_bhyve_startup_delay               | 5             | Delay in seconds between each VM to autostart.                                   |
| vm_bhhyve_host_shutdown_soft_timeout | 180           | Host shutdown soft timeout, according to `rc(8)`'s `rcshutdown_timeout` tunable. |
| vm_bhhyve_host_shutdown_hard_timeout | 240           | Host shutdown hard timeout, according to `sysctl kern.init_shutdown_timeout`.    |

Dependencies
------------

* Global variables provided by the consumer of the role:
  * `vm_bhyve_passthrough_devices`: List of PCI devices to reserve for PCI passthrough via the `pptdevs` `loader.conf(5)` variable, in standard `bus/slot/function` notation.
  * `vm_bhyve_startup_vms`: List of VMs to autostart up on system boot.

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

- name: Configure vm-bhyve
  hosts: all
  roles:
    - { role: ap_labs.freebsd_provisioning.vm_bhyve, tags: [vm_bhyve] }
```

Execution
---------

Run the orchestration playbook against your target inventory environment:

```sh
ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags vm_bhyve playbook.yml
```
