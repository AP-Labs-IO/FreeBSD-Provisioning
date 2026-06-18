Patch
=========

Patch a FreeBSD system with any updates that may be available via the freebsd-update(8) mechanism and reboot if necessary.

Requirements
------------

* A supported release of FreeBSD (see [supported releases](https://www.freebsd.org/security/#sup)).

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

- name: Patch
  hosts: all
  become: true
  roles:
    - patch
```

License
-------

Proprietary.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
