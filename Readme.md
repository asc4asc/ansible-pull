# Ansible Role: Discover Ethernet Ports

This Ansible role discovers all ethernet ports on target systems and makes them available as facts for use in subsequent tasks.

## Features

- Automatically discovers all ethernet interfaces (eth*, enp*, eno*, ens*)
- Collects detailed information about each interface
- **Checks if interfaces have IP addresses (IPv4 and IPv6)**
- **Tests internet connectivity via each interface (ping to 1.1.1.1)**
- Makes discovered ports available as Ansible facts
- Can optionally cache discovered facts
- Designed to be used in pre_tasks for availability throughout playbook

## Usage

### Basic Usage

```yaml
- name: My Playbook
  hosts: all
  gather_facts: false
  
  pre_tasks:
    - name: Discover ethernet ports
      ansible.builtin.include_role:
        name: discover_ethernet
  
  tasks:
    - name: Use discovered ports
      ansible.builtin.debug:
        msg: "Found ports: {{ discovered_ethernet_ports }}"
```

### With Details Display

```yaml
- name: Discover with details
  ansible.builtin.include_role:
    name: discover_ethernet
  vars:
    show_ethernet_details: true
```

### Run the Example Playbook

```bash
./run.sh
```

Or with specific inventory:

```bash
ansible-playbook site.yml -i your_inventory
```

## Available Facts After Discovery

- `discovered_ethernet_ports`: List of ethernet port names
- `discovered_ethernet_details`: Dictionary with detailed info for each port
- `discovered_interface_has_ip`: Dictionary with boolean values indicating if interface has an IP
- `discovered_interface_ipv4_addresses`: Dictionary with IPv4 addresses for each interface
- `discovered_interface_ipv6_addresses`: Dictionary with IPv6 addresses for each interface
- `discovered_interface_internet_connectivity`: Dictionary with boolean values indicating internet connectivity

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `show_ethernet_details` | `false` | Display detailed information about each port |
| `cache_ethernet_facts` | `false` | Cache discovered facts for reuse |
| `check_ip_addresses` | `true` | Check if interfaces have IP addresses |
| `check_internet_connectivity` | `true` | Test connectivity to internet via each interface |
| `internet_test_ip` | `1.1.1.1` | IP address to test internet connectivity |
| `ping_count` | `2` | Number of ping packets to send |
| `ping_timeout` | `5` | Timeout for ping in seconds |

## Examples

### Use in Network Configuration

```yaml
- name: Configure all ethernet ports
  ansible.builtin.template:
    src: interface.j2
    dest: "/etc/network/interfaces.d/{{ item }}"
  loop: "{{ discovered_ethernet_ports }}"
```

### Filter Specific Ports

```yaml
- name: Work only with active ports
  ansible.builtin.debug:
    msg: "{{ item }} is active"
  loop: "{{ discovered_ethernet_ports }}"
  when: discovered_ethernet_details[item].active | default(false)
```

### Check Interface IP and Connectivity Status

```yaml
- name: Show interfaces with IP addresses
  ansible.builtin.debug:
    msg: "{{ item }} has IP: {{ discovered_interface_ipv4_addresses[item] }}"
  loop: "{{ discovered_ethernet_ports }}"
  when: discovered_interface_has_ip[item] | default(false)

- name: Show interfaces with internet connectivity
  ansible.builtin.debug:
    msg: "{{ item }} has internet access"
  loop: "{{ discovered_ethernet_ports }}"
  when: discovered_interface_internet_connectivity[item] | default(false)

- name: Configure only interfaces with internet connectivity
  ansible.builtin.command:
    cmd: "echo 'Configuring {{ item }}'"
  loop: "{{ discovered_ethernet_ports }}"
  when: discovered_interface_internet_connectivity[item] | default(false)

- name: Configure only interfaces with no connectivity
  ansible.builtin.command:
    cmd: "echo 'Configuring {{ item }}'"
  loop: "{{ discovered_ethernet_ports_no_ip }}"
  when discovered_ethernet_ports_no_ip[item] | length > 0
```

### Custom Internet Test IP

```yaml
- name: Test connectivity to custom DNS server
  ansible.builtin.include_role:
    name: discover_ethernet
  vars:
    internet_test_ip: "8.8.8.8"
    ping_count: 3
```

## Author

Andreas Schockenhoff (asc@ekf.de)
