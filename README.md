Network
=========

Configure network related settings such as cloned interfaces, IPv4 & IPv6 settings, etc., as documented by `rc.conf(5)`.

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

| Variable                         | Default value | Description                                                     |
|----------------------------------|---------------|-----------------------------------------------------------------|
| network_enable_rtsold            | true          | Boolean toggle to enable the Router Solicitation daemon         |
| network_disable_bridge_filtering | true          | Boolean toggle to disable packet filtering on bridge interfaces |

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `network_renamed_interfaces`: List of dictionaries of network interfaces to rename, with attributes:
    * `src`: The original name of the interface.
    * `dst`: The desired name of the interface.
  * `network_vlan_interfaces`: List of dictionaries of VLAN interfaces to create, with attributes:
    * `parent`: The parent of the new VLAN interface.
    * `tag`: The VLAN tag for the new VLAN interface.
    * `ip4`: Optional IPv4 configuration of the VLAN.
    * `ip6`: Optional IPv6 configuration of the VLAN.
  * `network_bridge_interfaces`: List of dictionaries of network bridges to create, with attributes:
    * `name`: Desired name for the bridge.
    * `members`: Ordered list of bridge members. The first entry is configured as the `stp` member of the bridge.
    * `ip4`: Optional IPv4 configuration of the bridge.
    * `ip6`: Optional IPv6 configuration of the bridge.
  * `network_default_route_ip4`: IPv4 default router.
  * `network_default_route_ip6`: IPv6 default router.
  * `network_dns_resolver`: Dictionary proving a static DNS resolver configuration, according to `resolv.conf(5)`, with attributes:
    * `domain`: The local domain name.
    * `search`: Space-separated list of domain names for hostname lookups.
    * `nameservers`: A list of DNS IP addresses.
    * `options`: Space-separated list of system resolver customizations.

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

- name: Configure Network
  hosts: all
  become: true
  roles:
    - { role: network, tags: [network] }
```

License
--------

All Rights Reserved. Proprietary and Confidential.

Author Information
------------------

Juan Manuel Palacios (<jmpalacios@gmail.com>).
