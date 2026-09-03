Admins
======

Configure root & administrator users.

Requirements
------------

* A supported release of FreeBSD (see [supported releases](https://www.freebsd.org/security/#sup)).
* An already bootstrapped FreeBSD environment, i.e.:
  * With a Python runtime.
  * With key-based SSH access.
  * The `shells/bash` package installed.
  * A functional `become` setup.

The last set of requirements can be easily met by running the `ap_labs.bootstrap` as a precursor to this role.

Role Variables
--------------

None.

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `admins`: List of administrator users to copy shell configuration files for, each being a dictionary with attributes:
    * `name`: The administrator's username.
  * `shell_config_files`: List of file dictionaries with attributes:
    * `src`: Source basename of the shell configuration file to copy for each administrator user, expected to be found at a `shell/{{ src }}` files path.
    * `dst`: Target basename of the shell configuration file once copied into each administrator's home directory.

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

- name: Configure System Administrators
  hosts: all
  become: true
  roles:
    - { role: admins, tags: [admins] }
```

License
-------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
