# linux-admin-lab
## Infrastructure
| Role | Hostname | IP |
|----|----|----|
| Frontend (Nginx, Prometheus) | server1 | 192.168.118.128 |
| Backend1 (Apache, MySQL master, WordPress) | server2 | 192.168.118.129 |
| Backend2 (Apache, MySQL slave, backup) | server3 | 192.168.118.130 |

## Network
- VMware NAT (VMnet8)
- IPv4 via DHCP
