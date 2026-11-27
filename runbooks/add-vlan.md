# Runbook: Add a VLAN

Worked example and full background: [VLAN 20 writeup](../docs/networking/vlans/vlan20-isolated-wifi.md). If something doesn't come up, use the [layer-by-layer troubleshooting](../docs/networking/vlans/vlan20-isolated-wifi.md#troubleshooting-a-vlan-layer-by-layer).

Fill in before starting:

| | |
|---|---|
| VLAN ID (`N`) | |
| Name | |
| Subnet | `<vlanN-subnet>` |
| Gateway | `<vlanN-gateway>` |
| DHCP | `<vlanN-dhcp-range>` |
| Switch access port | |
| Internal services it may reach | |

**Order matters:** OPNsense first, then the switch, so the device has somewhere to land.

## 1. OPNsense

- [ ] **Interfaces → Devices → VLAN:** Parent `vtnet1`, Tag `N`, Description `<name>`
- [ ] **Interfaces → Assignments:** assign the new device, name it
- [ ] **Interfaces → `<name>`:** Enable; Static IPv4 `<vlanN-gateway>` / **24** (not /32); IPv6 None; Block private/bogon unchecked
- [ ] **Dnsmasq → General → Interface:** add `<name>`. Save, Apply. *(This was the Tenda failure.)*
- [ ] **Dnsmasq → DHCP ranges:** `<name>`, `.100`-`.200`. Save, Apply.
- [ ] **Firewall → Rules → `<name>`**, in order:
  1. Pass TCP/UDP → `<name>` address, port DOMAIN (53)
  2. Pass → each allowed internal service (service IP `/32` + port)
  3. Block any → `RFC1918`, **log on**
  4. Pass any → any
- [ ] **Apply changes.** Rules show green/red, not grey/white.

## 2. Proxmox

- [ ] Nothing, as long as the bridge is VLAN aware (`bridge -c vlan show` shows `2-4094`).

## 3. Switch (TL-SG108E)

From a wired machine on a port you're not changing:

- [ ] **802.1Q VLAN:** add VLAN `N`. Port 2 (trunk) Tagged, access port Untagged, rest Not Member.
- [ ] **802.1Q PVID:** access port → `N`
- [ ] **802.1Q VLAN → VLAN 1:** access port → Not Member
- [ ] Port 2 (trunk) still untagged in VLAN 1, PVID 1
- [ ] **Save Config**

## 4. Services

- [ ] Plex needed? Add `<vlanN-subnet>` to **LAN Networks** (keep existing entries).
- [ ] Wazuh agents on this VLAN? Allow 1514/1515 to `<wazuh-ip>`.

## 5. Verify

- [ ] Power-cycle the device → `<vlanN-subnet>` in Dnsmasq → Leases
- [ ] Allowed traffic works; `<opnsense-ip>` and Proxmox `:8006` time out and show in Live View

## 6. Document

- [ ] Copy [`templates/vlan.md`](../templates/vlan.md) to `docs/networking/vlans/vlanNN-<name>.md`
- [ ] Add a row to the [VLAN index](../docs/networking/vlans/README.md) and [addressing plan](../docs/networking/README.md#addressing-plan)
- [ ] Update the switch port table
- [ ] Add a CHANGELOG line
