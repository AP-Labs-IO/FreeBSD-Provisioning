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

The last set of requirements can be easily met by running the `ap_labs.bootstrap` role as a precursor to this one.

Role Variables
--------------

None.

Dependencies
------------

* Bootstrap role.
* `force_reboot`: Optional boolean that forces the reboot of the target node, even when the "Reboot" task determines by itself that it's not necessary. Default: `false`.

Example Ansible Configuration
-----------------------------

```ini
[defaults]
roles_path = ./roles

[privilege_escalation]
become = true
```

Example Requirements
--------------------

```yaml
---
- name: bootstrap
  src: git+ssh://git@gitlab.lan/ap-labs/ansible-roles/bootstrap.git
  version: main

- name: patch
  src: git+ssh://git@gitlab.lan/ap-labs/ansible-roles/patch.git
  version: main
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
    - { role: bootstrap, tags: [bootstrap] }

- name: Patch Operating System
  hosts: all
  become: true
  roles:
    - { role: patch, tags: [patch] }
```

Execution
---------

Run the master orchestration playbook against your target inventory environment:

```sh
-> ansible-galaxy role install -r requirements.yml -f -p ./roles
-> ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags patch playbook.yml
```

License
-------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
