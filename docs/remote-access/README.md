# Remote Access

Remote desktop to the Main PC uses a self-hosted [RustDesk server](rustdesk-server.md), reached over Tailscale. TODO: setup in progress.

## Tailscale

| Item | Value |
|---|---|
| Mode | Mesh VPN with subnet routing |
| Subnet router | OPNsense |
| Advertised routes | LAN (`<lan-subnet>`) |
| Split DNS | `hydralab.lan` → `<opnsense-ip>` (Unbound), *Restrict to domain*. *Override local DNS* off |

Tailnet devices resolve `*.hydralab.lan` names from anywhere through split DNS.

## Cloudflare Tunnel

Exposes selected services publicly without opening inbound ports on the ISP modem or OPNsense WAN.

Published hostnames, tunnel details and credentials are kept out of this repo.
