Patch
=====

FreeBSD OS patching via `freebsd-update(8)`.

Requirements
------------

* An already bootstrapped FreeBSD environment, i.e.:
  * With a Python runtime.
  * With key-based SSH access.
  * A functional `become` setup.

The last set of requirements can be easily met by running the `ap_labs.freebsd_provisioning.bootstrap` role as a precursor to this one.

Role Variables
--------------

None.

Dependencies
------------

None.

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

- name: Patch Operating System
  hosts: all
  roles:
    - { role: ap_labs.freebsd_provisioning.patch, tags: [patch] }
```

Execution
---------

Run the master orchestration playbook against your target inventory environment:

```sh
-> ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags patch playbook.yml
```
