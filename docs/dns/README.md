# DNS

## Current design

| Component | Port | Role |
|---|---|---|
| Unbound (OPNsense) | 53 | Recursive resolver for all segments, `hydralab.lan` host overrides |
| Dnsmasq (OPNsense) | 53053 | DHCP only. DNS listener moved off 53 so it doesn't collide with Unbound |

### `hydralab.lan` overrides

Under **Services → Unbound DNS → Overrides → Host Overrides**. Checked 2026-10-29; `vaultwarden` added 2026-10-30, `homepage` added 2026-11-01, `opnsense` added 2026-11-17, `grafana` and `influxdb` added 2026-11-25.

Every override points at the [Caddy reverse proxy](../networking/reverse-proxy.md) (`<caddy-ip>`), which serves HTTPS for the name and forwards to the real host. **Add PTR record** is off on all of them.

| Host | Domain | IP | Proxied to |
|---|---|---|---|
| `hydraserver` | `hydralab.lan` | `<caddy-ip>` | `<hydraserver-ip>:8006` |
| `nuc` | `hydralab.lan` | `<caddy-ip>` | `<nuc-ip>:8006` |
| `prodesk` | `hydralab.lan` | `<caddy-ip>` | `<prodesk-ip>:8006` |
| `elitedesk` | `hydralab.lan` | `<caddy-ip>` | `<elitedesk-ip>:8006` |
| `wazuh` | `hydralab.lan` | `<caddy-ip>` | `<wazuh-ip>:443` |
| `immich` | `hydralab.lan` | `<caddy-ip>` | `<immich-ip>:2283` |
| `wiki` | `hydralab.lan` | `<caddy-ip>` | `<wiki-ip>:3000` |
| `vaultwarden` | `hydralab.lan` | `<caddy-ip>` | `<vaultwarden-ip>:8000` |
| `homepage` | `hydralab.lan` | `<caddy-ip>` | `<homepage-ip>:3000` |
| `opnsense` | `hydralab.lan` | `<caddy-ip>` | `<opnsense-ip>:80` |
| `grafana` | `hydralab.lan` | `<caddy-ip>` | `<grafana-ip>:3000` |
| `influxdb` | `hydralab.lan` | `<caddy-ip>` | `<influxdb-ip>:8086` |
| `splunk` | `hydralab.lan` | `<caddy-ip>` | `<splunk-ip>:8000` |

Off the LAN, tailnet devices resolve `hydralab.lan` through Tailscale split DNS, which forwards those lookups to Unbound. See [Remote access](../remote-access/README.md#tailscale).

Plex has no override on purpose; it's reached by IP (`<plex-ip>:32400`).

### Rebind-protection exceptions

**Unbound → Advanced → Private Domains:** `plex.direct`. Required so Plex apps can resolve `*.plex.direct` to `<plex-ip>`. See [VLAN 20](../networking/vlans/vlan20-isolated-wifi.md#3f-unbound-dns).

## History: Pi-hole on Unraid

Pi-hole with Cloudflared (DNS-over-HTTPS upstream) previously ran on Unraid.

## Ideas

- Enable Unbound reporting / query logging and ship to Wazuh.
- Force DNS through Unbound on untrusted VLANs (block outbound 53/853). Rules are in the [VLAN 20 future work](../networking/vlans/vlan20-isolated-wifi.md#possible-future-work).
