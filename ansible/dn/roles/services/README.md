Bootstrap
=========

Configure services, such as `ntpd`, NFS, etc.

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

- name: Configure services
  hosts: all
  become: true
  roles:
    - services
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
