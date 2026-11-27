# Immich

| | |
|---|---|
| **Purpose** | Photo and video library |
| **Runs on** | LXC `127` on `HydraServerMox` (unprivileged), installed with the [community-scripts](https://community-scripts.org/scripts/immich) Immich helper script |
| **Hostname** | `https://immich.hydralab.lan`, via the [Caddy reverse proxy](../networking/reverse-proxy.md) |
| **Version** | TODO: |
| **Data location** | Mount point `mp0` at `/mnt/immich/photos`, 950G on `NVMe-local` (the `local-storage` ZFS pool on `HydraServerMox`) |
| **Backups** | `mp0` is included in Proxmox backups (`backup=1`). TODO: backup job and target |
| **Credentials** | `<see password manager>` |

## Install / config notes

From `/etc/pve/nodes/HydraServerMox/lxc/127.conf` (2026-10-28):

| Setting | Value |
|---|---|
| CPU / RAM / swap | 4 cores, 6 GiB, 512 MiB |
| Root disk | 20G raw image on `local` |
| Features | `nesting=1`, `keyctl=1` |
| GPU | `/dev/dri/renderD128` (gid 992) and `/dev/dri/card0` (gid 44) passed in |
| Network | `eth0` on `vmbr0`, `ip=dhcp` in Proxmox; address is fixed at `<immich-ip>` |
| Start on boot | Yes |
| Timezone | `America/Adak` (TODO: confirm; probably meant to be local time) |

## Dependencies

- `NVMe-local` storage on `HydraServerMox` for the photo library. It's the `local-storage` ZFS pool, a stripe of two ~500GB NVMe drives. See [Proxmox storage](../proxmox/README.md#storage).

## Firewall / access

TODO:

## Upgrade procedure

TODO:

## Known issues

- The 950G mount point is larger than the `local-storage` pool (940G), so the pool will fill up before Immich reaches its quota.
- `local-storage` has no redundancy: if either NVMe drive fails, the photo library is lost. Proxmox backups (`backup=1`) are the only other copy (TODO: backup job and target).
