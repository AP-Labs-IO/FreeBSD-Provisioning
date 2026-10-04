Users
=====

Create and configure users & groups.

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

| Variable                        | Default value    | Description                                    |
|---------------------------------|------------------|------------------------------------------------|
| users_disable_sensitive_logging | true             | Disable logging of potentially sensitive data. |
| users_accounts                  | []               | See `users_accounts` below.                    |
| users_groups                    | []               | See `users_groups` below.                      |
| users_extra_group_memberships   | []               | See `users_extra_group_memberships` below.     |
| users_minuid                    | 1000             | Minimum user id used by `pw(8)`.               |
| users_maxuid                    | 9999             | Maximum user id used by `pw(8)`.               |
| users_mingid                    | 1000             | Minimum group id used by `pw(8)`.              |
| users_maxgid                    | 9999             | Maximum group id used by `pw(8)`.              |
| users_mail_aliases              | []               | See `users_mail_aliases` below.                |

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `users_accounts`: List of dictionaries of users to create, with attributes:
    * `name`: The user's username.
    * `uid`: Optional UID of the user, defaulting to the next available UID.
    * `comment`: The user's full name.
    * `shell`: Optional full path to the chosen administrator's shell, defaulting to `/bin/sh`.
    * `password`: `ansible-vault` encrypted password for the user.
    * `salt`: Password salt in plain-text form.
    * `home`: Optional home path, defaulting to `/{{ users_home_prefix }}/{{ user.name }}`.
    * `key_type`: Optional SSH key type, defaulting to none.
  * `users_home_prefix`: Path prefix where user home directories are created by default.
  * `users_groups`: List of dictionaries of groups to create, with attributes:
    * `name`: The group's name.
    * `gid`: Optional GID of the group, defaulting to the next available GID.
  * `users_extra_group_memberships`: List of dictionaries of users extra group memberships, with attributes:
    * `user`: The user's username.
    * `groups`: List of groups the target user should be added to.
  * `users_smarthost_hostname`: FQDN for the `dma(8)` `SMARTHOST`.
  * `users_smarthost_port`: TCP port of the `dma(8)` `SMARTHOST`.
  * `users_smarthost_username`: Username for the `dma(8)` `SMARTHOST`.
  * `users_smarthost_password`: Corresponding password for the `users_smarthost_username`.
  * `users_mail_aliases`: List of dictionaries of user mail aliases, with attributes:
    * `user`: The target user's username.
    * `email`: The email address to direct the user's mail.

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

- name: users
  src: git+ssh://git@gitlab.lan/ap-labs/ansible-roles/users.git
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

- name: Create And Configure Users & Groups
  hosts: all
  become: true
  roles:
    - { role: users, tags: [users] }
```

Execution
---------

Run the master orchestration playbook against your target inventory environment:

```sh
-> ansible-galaxy role install -r requirements.yml -p ./roles
-> ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags users playbook.yml
```

License
-------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
