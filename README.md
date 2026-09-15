Bootstrap
=========

Bootstraps a fresh FreeBSD installation with latest Python, Bash, Bash shell completion, and admin accounts (full with SSH keys).

Requirements
------------

* A supported release of FreeBSD (see [supported releases](https://www.freebsd.org/security/#sup)).

Role Variables
--------------

| Variable                            | Default value | Description                                                                      |
|-------------------------------------|---------------|----------------------------------------------------------------------------------|
| bootstrap_disable_sensitive_logging | false         | Boolean that dictates whether task output considered sensitive is logged or not. |

Dependencies
------------

* SSH key of type `ed25519` located at the the top-level `files/keys/root_ed25519.pub` path.
* Global variables provided by the consumer of the role:
  * `admins`: List of administrator users to create, each being a dictionary with attributes:
    * `name`: The administrator's username.
    * `uid`: Optional UID of the administrator, defaulting to the next available `uid`.
    * `comment`: The administrator's full name.
    * `shell`: Full path to the chosen administrator's shell.
    * `password`: `ansible-vault` encrypted password for the administrator.
    * `salt`: Password salt in plain-text form.
    * `key_type`: Optional SSH key type.
* SSH key for each administrator user, located at a  `files/keys/{{ name }}_{{ type }}.pub` path that matches each administrator's `name` & `key_type` attributes.

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

Run the master orchestration playbook against your target inventory environment:

```sh
ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap playbook.yml
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
