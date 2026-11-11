Bootstrap
=========

Bootstraps a fresh FreeBSD installation for SSH key based Ansible management via a designated Ansible user.

Requirements
------------

As described in the top-level [`README.md`](../../README.md) file.

Role Variables
--------------

| Variable                             | Default value                              | Description                                                                      |
|--------------------------------------|--------------------------------------------|----------------------------------------------------------------------------------|
| bootstrap_sensitive_logging_disabled | true                                       | Boolean that dictates whether task output considered sensitive is logged or not. |
| bootstrap_toor_shell                 | {{ ansible_facts['local_base'] }}/bin/bash | toor's shell.                                                                    |
| bootstrap_core_packages              | See `bootstrap_core_packages` below.       | See `bootstrap_core_packages` below.                                             |

Dependencies
------------

* SSH key of type `ed25519` located at the the top-level `files/keys/root_ed25519.pub` path.
* Global variables provided by the consumer of the role:
  * `bootstrap_ansible_user`: Dictionary with attributes:
    * `name`: The administrator's username.
    * `uid`: Optional UID of the administrator, defaulting to the next available `uid`.
    * `comment`: The administrator's full name.
    * `shell`: Full path to the chosen administrator's shell.
    * `password`: `ansible-vault` encrypted password for the administrator.
    * `salt`: Password salt in plain-text form.
    * `key_type`: Optional SSH key type.
  * `bootstrap_core_packages`: List of "core" packages to install early, including the chosen shell for the `toor` user. Default:
    * `shells/bash`
    * `shells/bash-completion`
    * `shells/bash-completion-freebsd`
    * `shells/bash-completion-zfs`
* SSH key for each administrator user, located at a  `files/keys/{{ name }}_{{ type }}.pub` path that matches each administrator's `name` & `key_type` attributes.

Example Ansible Configuration
-----------------------------

```ini
[privilege_escalation]
become = true
```

Example Playbook
----------------

```yaml
- name: Bootstrap Node
  hosts: all
  become: false
  gather_facts: false
  vars: { ansible_user: root }
  roles:
    - { role: bootstrap, tags: [bootstrap] }
```

Execution
---------

Run the orchestration playbook against your target inventory environment:

```sh
ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap playbook.yml
```
