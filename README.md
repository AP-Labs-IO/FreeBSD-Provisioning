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

| Variable                           | Default value | Description                                                                                                             |
|----------------------------------  |---------------|-------------------------------------------------------------------------------------------------------------------------|
| network_enable_rtsold              | true          | Boolean toggle to enable the Router Solicitation daemon.                                                                |
| network_remove_stock_configuration | false         | Boolean toggle to to remove the node's stock network configuration. See `network_preserve_custom_configurations` below. |
| network_renamed_interfaces         | []            | See `network_renamed_interfaces` below.                                                                                 |
| network_base_interfaces            | []            | See `network_base_interfaces` below.                                                                                    |
| network_vlan_interfaces            | []            | See `network_vlan_interfaces` below.                                                                                    |
| network_bridge_interfaces          | []            | See `network_bridge_interfaces` below.                                                                                  |
| network_disable_bridge_filtering   | true          | Boolean toggle to disable packet filtering on bridge interfaces.                                                        |

Dependencies
------------

* Bootstrap role.
* Global variables provided by the consumer of the role:
  * `network_preserve_custom_configurations`: Regular expression segment that matches the custom network configurations that should NOT be removed from `/etc/rc.conf` when `network_remove_stock_configuration` is set to `true`, e.g.: `(igb|vtnet)([0-9]+_name|[0-9]+_[0-9]+)|bridge|.+up`. This pattern is first prepended with an `ifconfig_` clause anchored to the beginning of the line, and then negated with "negative lookahead", causing the full regular expression to skip all lines matched by the full regular expression. For the example provided, the preserved configurations would be:
    * Renaming of any `igb` or `vtnet` interface, e.g. `ifconfig_igb0_name="$customName"` or `ifconfig_vtnet1="$customName"`.
    * IP configuration for any VLAN interface based on `igb` or `vtnet` devices, utilizing the standard `device_tag` naming convention, e.g. `ifconfig_igb0_10="$ipConfig"`, `ifconfig_vtnet1_40="$ipConfig"`, or `ifconfig_igb0_50_ipv6="$ipv6Config"`.
    * Creation and/or IP configuration for any bridges, e.g. `ifconfig_bridge10="$bridgeConfig"` or `ifconfig_bridge40_ipv6="$ipv6Config"`.
    * Any "up" interface, e.g. `ifconfig_lagg0="up"`.
  * `network_renamed_interfaces`: List of dictionaries of network interfaces to rename, with attributes:
    * `src`: The original name of the interface.
    * `dst`: The desired name of the interface.
  * `network_base_interfaces`:
    * `name`: Desired name for the interface.
    * `mtu`: Optional MTU setting for the interface.
    * `ip4`: Optional IPv4 configuration of the VLAN interface.
    * `ip6`: Optional IPv6 configuration of the VLAN interface.
  * `network_vlan_interfaces`: List of dictionaries of VLAN interfaces to create, with attributes:
    * `parent`: The common parent of a group of VLAN interfaces. This value is expected to be unique across all VLAN list entries.
    * `vlans`: List of child VLAN interfaces of a common parent, with attributes:
      * `tag`: The VLAN tag for the new VLAN interface.
      * `mtu`: Optional MTU setting for the interface.
      * `ip4`: Optional IPv4 configuration of the VLAN interface.
      * `ip6`: Optional IPv6 configuration of the VLAN interface.
  * `network_bridge_interfaces`: List of dictionaries of network bridges to create, with attributes:
    * `name`: Desired name for the bridge.
    * `members`: Ordered list of bridge members. The first entry is configured as the `stp` member of the bridge.
    * `mtu`: Optional MTU setting for the interface.
    * `ip4`: Optional IPv4 configuration of the bridge interface.
    * `ip6`: Optional IPv6 configuration of the bridge interface.
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
