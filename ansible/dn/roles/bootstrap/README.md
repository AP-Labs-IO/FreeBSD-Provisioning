Bootstrap
=========

Bootstraps a fresh FreeBSD installation with latest Python, Bash, Bash shell completion, and admin accounts (full with SSH keys).

Requirements
------------

* A supported release of FreeBSD (see [supported releases](https://www.freebsd.org/security/#sup)).

Role Variables
--------------

None.

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- name: Bootstrap Node
  hosts: all
  become: false
  gather_facts: false
  vars:
    ansible_user: root
  roles:
    - role: bootstrap
      tags:
        - bootstrap
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
