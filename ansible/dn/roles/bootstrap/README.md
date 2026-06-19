Bootstrap
=========

Bootstraps a fresh FreeBSD installation with latest Python, Bash, Bash shell completion, and admin accounts (full with SSH keys).

Requirements
------------

* A supported release of FreeBSD (see [supported releases](https://www.freebsd.org/security/#sup)).

Role Variables
--------------

| Variable | Description                                                                                                                                                                  |
|----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| bootstrap_admins | List of administrator users, with each entry being a dictionary with `name`, `comment`, `groups` (list), `shell`, `password` (encrypted), `salt`, and `key_type` attributes. |

Dependencies
------------

None.

Example Playbook
----------------

```yaml
- name: Bootstrap
  hosts: all
  become: false
  gather_facts: false
  vars:
    ansible_user: root
  roles:
    - bootstrap
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
