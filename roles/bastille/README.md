Bastille
========

Configure FreeBSD nodes to host [Bastille](https://bastillebsd.org/projects/bastille/) jails.

Requirements
------------

* An already bootstrapped FreeBSD environment, i.e.:
  * With a Python runtime.
  * With key-based SSH access.
  * A functional `become` setup.

The last set of requirements can be easily met by running the [`ap_labs.freebsd_provisioning.bootstrap`](../bootstrap/README.md) role as a precursor to this one.

Role Variables
--------------

| Variable                    | Default value                              | Description                                                    |
|-----------------------------|--------------------------------------------|----------------------------------------------------------------|
| bastille_prefix             | {{ ansible_facts['local_base'] }}/bastille | Where jails, releases, templates, backpus etc lives.           |
| bastille_tzdata             | ""                                         | Timezone for Bastille jails.                                   |
| bastille_zfs_enable         | YES                                        | Set to YES to enable some ZFS magic (recommended).             |
| bastille_zfs_zpool          | zroot                                      | The ZFS pool where Bastille will host its files and jails.     |
| bastille_default_release    | 14.4-RELEASE                               | FreeBSD release used by default when deploying Bastille jails. |
| bastille_default_ip_options | DHCP SLAAC                                 | IP options used by default when deploying Bastille jails.      |
| bastille_ops_path           | /root                                      | Path where the Bastille "operations" tree is created.          |

Dependencies
------------

* Global variables provided by the consumer of the role:
  * `bastille_releases`: List of strings with the names of the FreeBSD releases that Bastille should bootstrap.
  * `bastille_templates_repository`: URL of the Bastille templates repository to use for the deployment of jails.

Example Ansible Configuration
-----------------------------

```ini
[privilege_escalation]
become = true
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
    - { role: ap_labs.freebsd_provisioning.bootstrap, tags: [bootstrap] }

- name: Configure Bastille Jail Hosting
  hosts: all
  roles:
    - { role: ap_labs.freebsd_provisioning.bastille, tags: [bastille] }
```

Execution
---------

Run the orchestration playbook against your target inventory environment:

```sh
ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags bastille playbook.yml
```

Included is a simple helper script that aims to simplify the process of creating clone jails that potentially use dashes in their names, which the `/usr/share/examples/jails/jib` script employed by Bastille when first creating a jail does not allow.

Additionally, this helper script, installed at the `{{ bastille_ops_path }}/deployments/scripts/create-bastille-jail.s` path, performs the following actions for the target jail:

* Attaches it to the provided network bridge.
* Bootstraps the Bastille templates repository defined by the `bastille_templates_repository` variable.
* Applies the requested template to the jail.
* Copies any requested tree of files into the jail.
* Applies any requested tags to the jail.
