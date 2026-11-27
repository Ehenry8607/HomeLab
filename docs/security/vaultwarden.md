# Vaultwarden

| | |
|---|---|
| **Purpose** | Self-hosted password manager (Bitwarden-compatible). Single store for lab passwords, API keys, and SSH key records |
| **Runs on** | LXC `110` on `elitedesk-worker` |
| **IP / port** | `https://vaultwarden.hydralab.lan`. Upstream address in the [static-address table](../networking/README.md#static--reserved-addresses) |
| **Hostname** | `vaultwarden.hydralab.lan` (via [Caddy](../networking/reverse-proxy.md#proxied-services)) |
| **Version** | TODO: (Admin panel → Diagnostics) |
| **Data location** | TODO: data directory inside the LXC |
| **Backups** | TODO: |
| **Credentials** | Master password is not stored anywhere. Admin token: `<see password manager>` |

## Install / config notes

- Vaultwarden serves its own HTTPS on port `8000` with a self-signed certificate (`CN=vaultwarden.internal`). Caddy terminates TLS with the `*.hydralab.lan` wildcard cert and forwards to it without verifying the upstream cert, the same pattern as the Proxmox and Wazuh web UIs.
- TODO: set `DOMAIN=https://vaultwarden.hydralab.lan` in Vaultwarden's config so attachment and invite links use the proxied name.

## Clients

| Client | Machines | Notes |
|---|---|---|
| Bitwarden CLI (`bw`) | `E16` (Arch), TODO: `TheMonster` (Fedora) | `bw config server https://vaultwarden.hydralab.lan`. Needs `NODE_EXTRA_CA_CERTS` pointing at the system CA bundle, since Node ignores the system store |
| Web vault | Any browser | Device must trust the [HydraLab Root CA](../networking/reverse-proxy.md#certificates) |

Every client needs two things to reach the vault by name:

1. **DNS for `hydralab.lan`**: Unbound on the LAN; Tailscale split DNS when away. See [Remote access](../remote-access/README.md#tailscale).
2. **Trust in the HydraLab Root CA**, or the wildcard cert is rejected.

## Dependencies

- [Caddy](../networking/reverse-proxy.md) for the `vaultwarden.hydralab.lan` name. If Caddy is down, the vault is still reachable on its upstream address, but clients configured for the name stop working.
- Unbound host override `vaultwarden` → Caddy. See [DNS](../dns/README.md#hydralablan-overrides).

## Firewall / access

LAN and tailnet only. Not exposed through Cloudflare Tunnel.

## Known issues

- Vaultwarden runs inside the lab it protects. If `elitedesk-worker` is down, clients fall back to their offline copy, and new logins or unlocks against the server fail.
