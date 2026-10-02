Bastille
========

Configure FreeBSD nodes to host Bastille jails.

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

| Variable            | Default value       | Description                                                |
|---------------------|---------------------|------------------------------------------------------------|
| bastille_prefix     | /usr/local/bastille | Where jails, releases, templates, backpus etc lives.       |
| bastille_tzdata     |                     | Timezone for Bastille jails.                               |
| bastille_zfs_enable | YES                 | Set to YES to enable some ZFS magic (recommended).         |
| bastille_zfs_zpool  | zroot               | The ZFS pool where Bastille will host its files and jails. |

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `bastille_releases`: List of strings with the names of the FreeBSD releases that Bastille should bootstrap.

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

- name: bastille
  src: git+ssh://git@gitlab.lan/ap-labs/ansible-roles/bastille.git
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

- name: Configure Bastille Jail Hosting
  hosts: all
  become: true
  roles:
    - { role: bastille, tags: [bastille] }
```

Execution
---------

Run the master orchestration playbook against your target inventory environment:

```sh
-> ansible-galaxy role install -r requirements.yml -f -p ./roles
-> ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags bastille playbook.yml
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
