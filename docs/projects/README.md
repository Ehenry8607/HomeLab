# Lab Projects & Design Notes

Exploratory work that isn't (yet) part of the running lab.

## Local LLM on the RTX 3070

**Goal:** run a local LLM on the RTX 3070 in `HydraServerMox`.

**Status:** idea. The card isn't installed yet. Setup plan: [local-llm.md](local-llm.md) (Ubuntu Server VM with the GPU passed through).

**Open questions:**

- **Model size:** the 3070 has 8GB of VRAM. Models around 7-8B parameters at 4-bit quantization fit; larger ones spill into system RAM and slow down a lot.
- **Software:** Ollama to serve models, Open WebUI as an optional chat front end.
- **Host resources:** TODO: CPU, total RAM, PSU wattage, and a free x16 slot in `HydraServerMox`.

## Script ideas

- **Inventory generator:** pull nodes, VMs, and LXCs from the Proxmox API into a Markdown table for these docs.
- **Backup checker:** confirm every VM and LXC has a recent successful backup and flag any that are stale.
- **Health report:** daily summary of cluster quorum, ZFS pool status, and disk usage per node.
- **Service up checker:** probe each service on the Homepage dashboard and alert when one stops responding.
- **VLAN 20 isolation test:** from a guest device, confirm internet and Plex work and everything else on the LAN times out.
- **LXC updater:** update packages across LXCs one at a time, snapshotting each first.
- **DNS sync:** generate Unbound `hydralab.lan` host overrides from the Proxmox inventory so hostnames stay current.
- **New-service bootstrap:** create the LXC, add its DNS override and Homepage entry, and start its doc from `templates/service.md`.

## Network ideas

- Replace the guest AP with a VLAN-tagging AP (Omada / UniFi) serving multiple SSIDs.
- IoT VLAN.
- Management VLAN for Proxmox, switch, and AP admin interfaces.
