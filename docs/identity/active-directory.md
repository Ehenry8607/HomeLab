# Active Directory Lab

| Item | Value |
|---|---|
| Domain (NetBIOS) | `HYDRALAB` |
| Domain (FQDN) | `hydralabs.local` |
| Domain controllers | `WIN-DC01` (`<dc01-ip>`, VM `106` on `HydraServerMox`), `WIN-DC02` (`<dc02-ip>`, VM `125` on `elitedesk-worker`) |
| Functional level | TODO: |

`WIN-DC01` and `WIN-DC02` run Windows Server 2019.

Purpose: a target domain for practicing AD attacks later. Personal PCs are not joined to it, so nothing outside the domain needs to resolve `hydralabs.local`.

## Design

- Two DCs for redundancy; each runs DNS for the AD zone.
- `WIN-DC01` has 8GB of RAM and runs only AD; plan is to lower it to free memory on `HydraServerMox`. Most AD-related services will go on `WIN-DC02` once it's running, since `elitedesk-worker` has plenty of RAM to spare.
- TODO: OU structure, GPOs, service accounts.

## Related

- [Wazuh agent on the DC](../security/wazuh.md#agents).
