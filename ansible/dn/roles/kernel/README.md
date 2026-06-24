Bootstrap
=========

Configure runtime kernel state, as documented by `sysctl(8)`.

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
- name: Bootstrap
  hosts: all
  become: false
  gather_facts: false
  vars:
    ansible_user: root
  roles:
    - bootstrap

- name: Configure kernel
  hosts: all
  become: true
  roles:
    - kernel
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
