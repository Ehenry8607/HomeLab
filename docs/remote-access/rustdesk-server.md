# RustDesk Server

> **Status: TODO, setup in progress.** The server is running, but no remote session has been tested yet. See [Open items](#open-items).

| | |
|---|---|
| **Purpose** | Self-hosted ID and relay server for RustDesk, for reaching the Main PC from `E16` when away from home |
| **Runs on** | LXC `128` (`rustdeskserver`), `elitedesk-worker` |
| **IP / port** | TODO: confirm IP. RustDesk ports answer at `<rustdesk-ip>`, not yet confirmed to be this LXC. Ports `21114`-`21119` |
| **Hostname** | TODO: none yet (`rustdesk.hydralab.lan` does not resolve) |
| **Version** | TODO: |
| **Data location** | `/var/lib/rustdesk-server/` |
| **Backups** | TODO: |
| **Credentials** | `<see password manager>` |

## Install / config notes

Clients need two values: the server address and the server's public key. The public key is at `/var/lib/rustdesk-server/id_ed25519.pub`. The matching private key `id_ed25519` is in the same folder and never leaves the server.

TODO: how the server was installed, and what provides the web panel on `21114`.

### Clients

| Device | OS | Install | State |
|---|---|---|---|
| `E16` | Arch | Flatpak `com.rustdesk.RustDesk`, user install | Pointed at this server. Not yet tested |
| Main PC (`<main-pc-ip>`) | Fedora and Windows dual boot, Fedora in daily use | TODO: | Not set up |

## Dependencies

- [Tailscale](README.md#tailscale) subnet routing on OPNsense (`<opnsense-ip>`), which carries client traffic when away from home.

## Firewall / access

Intended access is over Tailscale only, with no port forwards on the WAN.

| Port | Proto | Purpose |
|---|---|---|
| 21114 | TCP | Web admin panel |
| 21115 | TCP | NAT type test |
| 21116 | TCP/UDP | ID registration and hole punching. UDP not tested |
| 21117 | TCP | Relay |
| 21118 | TCP | Web client (WebSocket) |
| 21119 | TCP | Web client relay (WebSocket) |

## Upgrade procedure

TODO:

## Known issues

- RustDesk's Wayland support on Linux is limited. It can require approving screen sharing at the PC, and may not work at the login screen. This is a lockout risk for unattended access on Fedora.

## Open items

- TODO: confirm LXC `128` is `<rustdesk-ip>`.
- TODO: add a static DHCP mapping. `<rustdesk-ip>` is inside the DHCP range, and no mapping is recorded for it. Then add it to the [static-address table](../networking/README.md).
- TODO: check the Main PC's Fedora version and session type, then install the client.
- TODO: confirm the Main PC boots Fedora by default, and stays reachable (sleep settings or Wake-on-LAN).
- TODO: test a session from `E16` off the home network.
- TODO: decide on a hostname and DNS entry.
