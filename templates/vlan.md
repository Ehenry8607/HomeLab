# VLAN N: <Name>

<One sentence: what this segment is for.>

| | |
|---|---|
| **Created** | YYYY-MM-DD |
| **VLAN** | N |
| **Subnet** | `<vlanN-subnet>` |
| **Gateway** | `<vlanN-gateway>` |
| **DHCP** | `<vlanN-dhcp-range>` |
| **Switch port(s)** | |
| **Devices / SSID** | |

## Allowed internal access

| Destination | Port | Why |
|---|---|---|
| | | |

## Firewall rules

| # | Action | Protocol | Source | Destination | Port | Log | Description |
|---|---|---|---|---|---|---|---|
| 1 | Pass | TCP/UDP | <Name> net | <Name> address | DOMAIN (53) | | Allow DNS |
| 2 | Pass | | <Name> net | | | | |
| 3 | Block | any | <Name> net | RFC1918 | any | ✅ | Block internal |
| 4 | Pass | any | <Name> net | any | any | | Allow internet |

## Verification

| Test | Expected | Result |
|---|---|---|
| Device gets lease | `<vlanN-subnet>` | |
| Allowed service works | | |
| `<opnsense-ip>` blocked + logged | Timeout | |

## Notes / issues
