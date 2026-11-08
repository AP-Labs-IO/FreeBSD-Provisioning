# FreeBSD Infrastructure Provisioning Collection

This Ansible collection provides a comprehensive framework for bootstrapping, configuring, securing, and maintaining **FreeBSD** nodes. It consolidates system initialization & configuration, runtime performance tuning, storage management, network layouts, file sharing, and monitoring into a single namespace.

---

## Included Roles

The collection is broken down into modular roles designed to be executed sequentially or independently, with as little interdependencies as possible:

### Foundational Setup

* **`bootstrap`**: Initial node provisioning. Extended documentation for the role can be found in the `roles/bootstrap/README.md` file.
* **`patch`**: Host OS updates. Extended documentation for the role can be found in the `roles/patch/README.md` file.
* **`host_tuning`**: Limited host hardware configuration. Extended documentation for the role can be found in the `roles/host_tuning/README.md` file.
* **`boot`**: Boot-time configuration. Extended documentation for the role can be found in the `roles/boot/README.md` file.

### Runtime Configuration & Tuning

* **`runtime`**: Runtime tuning. Extended documentation for the role can be found in the `roles/runtime/README.md` file.
* **`network`**: Network configuration. Extended documentation for the role can be found in the `roles/network/README.md` file.
* **`users`**: Users & groups. Extended documentation for the role can be found in the `roles/users/README.md` file..

### Storage & File Sharing

* **`zfs`**: ZFS pools & datasets management. Extended documentation for the role can be found in the `roles/zfs/README.md` file.
* **`nfs_server`**: NFSv4 server & shares configuration. Extended documentation for the role can be found in the `roles/nfs_server/README.md` file.
* **`nfs_client`**: NFS client & automatic shares mounting. Extended documentation for the role can be found in the `roles/nfs_client/README.md` file.
* **`samba_server`**: Samba server, shares, & users management. Extended documentation for the role can be found in the `roles/samba_server/README.md` file.

## Virtualization

* **`vm_bhyve`**: Bhyve VMs management via the `sysutils/vm-bhyve` package. Extended documentation for the role can be found in the `roles/vm_bhyve/README.md` file.
* **`bastille`**: Jails management via the `sysutils/bastille` package. Extended documentation for the role can be found in the `roles/bastille/README.md` file.

### Observability

* **`monitoring`**: Basic monitoring for the host's security, hardware, storage, and services layers. Extended documentation for the role can be found in the `roles/monitoring/README.md` file.

---

## Installation

Configure the collection in your Ansible project's `requirements.yml` file as a `git+ssh` dependency:

```yaml
---
collections:
  - name: git+ssh://git@github.com/AP-Labs-IO/freebsd-provisioning.git
    version: main
```

Install it via `ansible-galaxy`:

```bash
-> ansible-galaxy collection install -r requirements.yml
```

---

## Usage Example

Example playbooks for projects consuming individual roles within this collection are provided in the `README.md` files for each of them. These may be freely combined into a single complex playbook when consuming multiple roles at once.

---

## Requirements & Target Compatibility

* Ansible Core version: `>= 2.20.0`
* Target Operating System: A supported release of FreeBSD (see [supported releases](https://www.freebsd.org/security/#sup)).
* Role-specific requirements are documented in each role's `README.md` file, as mapped out above.

---

## License

All Rights Reserved. Proprietary and Confidential.

## Author Information

Juan Manuel Palacios (<jmpalacios@gmail.com>).
