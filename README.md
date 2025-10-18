# Terraform Proxmox Flatcar VM

A docker compose based Uptime Kuma instance, on a Flatcar VM running on Proxmox.

The Uptime Kuma instance is run as a docker container, with a mariadb container.
A single ZFS ZVol is used for storage.


**Note:** This configuration excludes a reverse proxy with TLS offload. This is all
handled elsewhere.

# Links

- https://uptimekuma.org/
- https://github.com/louislam/uptime-kuma
- https://registry.terraform.io/modules/lucidsolns/flatcar-vm/proxmox/latest
- https://github.com/lucidsolns/terraform-proxmox-flatcar-vm
- https://github.com/louislam/uptime-kuma/issues/5676