# Plex

| | |
|---|---|
| **Purpose** | Media server for the household and invited guests |
| **Runs on** | VM `103` (PlexServer, Ubuntu Server) on `nuc-worker` |
| **IP / port** | `<plex-ip>`, port `32400` |
| **Hostname** | None; reached by IP (`<plex-ip>:32400`) |
| **Version** | TODO: |
| **Data location** | Unraid array (8TB Seagate on `HydraServerMox`), made available to `nuc-worker` (TODO: share type and mount path) |
| **Backups** | TODO: |
| **Credentials** | `<see password manager>` |

## Install / config notes

### Transcoding: QuickSync passthrough

Intel QuickSync, with the NUC's iGPU passed through to VM `103`.

TODO: record the passthrough config (the `hostpci` line from `qm config 103`) so this can be rebuilt.

### Network settings

Web UI: `http://<plex-ip>:32400/web` → **Settings → Network → Show Advanced**

| Setting | Value |
|---|---|
| LAN Networks | `<lan-subnet>,<vlan20-subnet>` (add every VLAN that should count as local) |
| Allowed without auth | *(empty)* |

### Sharing

Guests are invited by email with specific libraries, never added to Plex Home. Guest WiFi access is described in [VLAN 20](../networking/vlans/vlan20-isolated-wifi.md).

## Dependencies

- Unbound private domain `plex.direct` (rebind-protection exception). See [DNS](../dns/README.md#rebind-protection-exceptions).
- Library storage: the Unraid array on `HydraServerMox` (TODO: share type and mount path).
- Download and media paths shared with the *arr stack: see [Media stack paths](README.md#paths).

## Firewall / access

- LAN (`<lan-subnet>`): full access.
- VLAN 20 (Isolated_WiFi): only TCP `32400` to `<plex-ip>/32` is allowed. See the [VLAN 20 firewall rules](../networking/vlans/vlan20-isolated-wifi.md).
- Adding a new VLAN that needs Plex: add its subnet to **LAN Networks** (keep existing entries). See the [add-a-VLAN runbook](../../runbooks/add-vlan.md#4-services).

## Upgrade procedure

TODO:

## Known issues

- Without `plex.direct` in Unbound's private domains, rebind protection blocks `*.plex.direct` lookups and Plex reports the server as unavailable even when the firewall rules are correct.
- GDM local discovery broadcasts don't cross VLANs. Clients on other VLANs find the server through plex.tv instead.
