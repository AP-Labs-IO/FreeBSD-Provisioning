Network
=======

Configure network related settings such as cloned interfaces, IPv4 & IPv6 settings, etc., as documented by `rc.conf(5)`.

Requirements
------------

* An already bootstrapped FreeBSD environment, i.e.:
  * With a Python runtime.
  * With key-based SSH access.
  * A functional `become` setup.

The last set of requirements can be easily met by running the `ap_labs.freebsd_provisioning.bootstrap` role as a precursor to this one.

Role Variables
--------------

| Variable                           | Default value | Description                                                                                                             |
|----------------------------------  |---------------|-------------------------------------------------------------------------------------------------------------------------|
| network_max_socket_buffer_size     | 16777216      | Max socket buffer size, according to `sysctl kern.ipc.maxsockbuf`.                                                      |
| network_rtsold_enabled             | true          | Boolean toggle to enable the Router Solicitation daemon.                                                                |
| network_remove_stock_configuration | false         | Boolean toggle to to remove the node's stock network configuration. See `network_preserve_custom_configurations` below. |
| network_renamed_interfaces         | []            | See `network_renamed_interfaces` below.                                                                                 |
| network_base_interfaces            | []            | See `network_base_interfaces` below.                                                                                    |
| network_vlan_interfaces            | []            | See `network_vlan_interfaces` below.                                                                                    |
| network_bridge_interfaces          | []            | See `network_bridge_interfaces` below.                                                                                  |
| network_bridge_filtering_disabled  | true          | Boolean toggle to disable packet filtering on bridge interfaces.                                                        |
| network_send_buffer_size           | 1048576       | Initial send socket buffer size, according to ` sysctl net.inet.tcp.sendspace`.                                         |
| network_receive_buffer_size        | 1048576       | Initial receive socket buffer size, according to ` sysctl net.inet.tcp.recvspace`.                                      |
| network_receive_delayed_ack        | 0             | TCP ACK delay, according to ` sysctl net.inet.tcp.delayed_ack`.                                                         |

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
    * `opts`: Optional interface configurations, e.g. `-txcsum`.
  * `network_vlan_interfaces`: List of dictionaries of VLAN interfaces to create, with attributes:
    * `parent`: The common parent of a group of VLAN interfaces. This value is expected to be unique across all VLAN list entries.
    * `vlans`: List of child VLAN interfaces of a common parent, with attributes:
      * `tag`: The VLAN tag for the new VLAN interface.
      * `mtu`: Optional MTU setting for the interface.
      * `ip4`: Optional IPv4 configuration of the VLAN interface.
      * `ip6`: Optional IPv6 configuration of the VLAN interface.
      * `opts`: Optional interface configurations.
  * `network_bridge_interfaces`: List of dictionaries of network bridges to create, with attributes:
    * `name`: Desired name for the bridge.
    * `members`: Ordered list of bridge members. The first entry is configured as the `stp` member of the bridge.
    * `mtu`: Optional MTU setting for the interface.
    * `ip4`: Optional IPv4 configuration of the bridge interface.
    * `ip6`: Optional IPv6 configuration of the bridge interface.
    * `opts`: Optional interface configurations.
  * `network_default_route_ip4`: IPv4 default router.
  * `network_default_route_ip6`: IPv6 default router.
  * `network_dns_resolver`: Dictionary proving a static DNS resolver configuration, according to `resolv.conf(5)`, with attributes:
    * `domain`: The local domain name.
    * `search`: Space-separated list of domain names for hostname lookups.
    * `nameservers`: A list of DNS IP addresses.
    * `options`: Space-separated list of system resolver customizations.

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

- name: Configure Network
  hosts: all
  roles:
    - { role: ap_labs.freebsd_provisioning.network, tags: [network] }
```

Execution
---------

Run the master orchestration playbook against your target inventory environment:

```sh
-> ansible-playbook -v --diff -i inventory/$env.yml --tags bootstrap --tags network playbook.yml
```
