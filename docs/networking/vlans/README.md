# VLANs

One document per VLAN. To add a new one, follow the [add-a-VLAN runbook](../../../runbooks/add-vlan.md), then copy [`templates/vlan.md`](../../../templates/vlan.md) to `vlanNN-<name>.md` here.

| VLAN | Name | Subnet | Purpose | Internal access | Doc |
|---|---|---|---|---|---|
| 1 | LAN | `<lan-subnet>` | Trusted devices, servers | Full | [Networking](../README.md) |
| 20 | Isolated_WiFi | `<vlan20-subnet>` | Guest / untrusted WiFi | Plex `<plex-ip>:32400` only | [vlan20-isolated-wifi.md](vlan20-isolated-wifi.md) |

## Reserved / planned

| VLAN | Idea |
|---|---|
| TODO: | e.g. IoT, management, lab/attack range |
