Bastille
=========

Configure FreeBSD nodes to host Bastille jails.

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

| Variable            | Default value       | Description                                                |
|---------------------|---------------------|------------------------------------------------------------|
| bastille_prefix     | /usr/local/bastille | Where jails, releases, templates, backpus etc lives.       |
| bastille_tzdata     |                     | Timezone for Bastille jails                                |
| bastille_zfs_enable | YES                 | Set to YES to enable some ZFS magic (recommended).         |
| bastille_zfs_zpool  | zroot               | The ZFS pool where Bastille will host its files and jails. |
| bastille_releases   | 14.4-RELEASE        | List of releases to be available for jails creation.       |

Dependencies
------------

* Bootstrap role.

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

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
