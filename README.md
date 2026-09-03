Patch
=====

FreeBSD OS patching via `freebsd-update(8)`.

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

None.

Dependencies
------------

* Bootstrap role.
* `force_reboot`: Optional boolean that forces the reboot of the target node, even when the "Reboot" task determines by itself that it's not necessary. Default: `false`.

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

- name: Patch Operating System
  hosts: all
  become: true
  roles:
    - { role: patch, tags: [patch] }
```

License
-------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
