Boot
=========

Configure boot-time settings, such as kernel modules and tunables, as documented by `loader(8)` & `rc.conf(5)`.

Requirements
------------

* A supported release of FreeBSD (see [supported releases](https://www.freebsd.org/security/#sup)).
* An already bootstrapped FreeBSD environment, i.e.:
  * With a Python runtime.
  * With key-based SSH access.
  * A functional `become` setup.

The last set of requirements can be easily met by running the `bootstrap` as a precursor to this role.

Role Variables
--------------

None.

Dependencies
------------

* Bootstrap role.

Example Playbook
----------------

```yaml
---
- name: Bootstrap Nodes
  hosts: all
  become: false
  gather_facts: false
  vars:
    ansible_user: root
  roles:
    - role: bootstrap
      tags:
        - bootstrap

- name: Configure Early Boot Environment
  hosts: all
  become: true
  roles:
    - role: boot
      tags:
        - boot
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
