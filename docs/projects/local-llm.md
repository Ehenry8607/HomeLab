# Local LLM on HydraServerMox

Plan for running a local LLM on an RTX 3070 in `HydraServerMox`, inside an Ubuntu Server VM with the GPU passed through. Status: **not started**; the card isn't installed yet.

## Options

### Runtimes

| Runtime | What it is | Fit here |
|---|---|---|
| **Ollama** | One-command install, runs as a service, pulls models by name, OpenAI-compatible API on port `11434` | **Start here.** Easiest to run and update |
| llama.cpp (`llama-server`) | The engine Ollama is built on, run directly with GGUF model files | More tuning control, more manual work |
| vLLM | High-throughput server for many simultaneous users | Built for bigger GPUs; little benefit on 8GB for one user |

### Front ends

| Front end | What it is |
|---|---|
| **Open WebUI** | ChatGPT-style web UI that talks to Ollama. Accounts, chat history, document upload |
| None | Use the Ollama CLI (`ollama run`) or its API from scripts and tools like n8n |

### Models that fit 8GB of VRAM

The 3070 has 8GB of VRAM. At 4-bit quantization (Ollama's default), a model needs roughly 0.6GB per billion parameters plus some room for context:

| Size | Approx. VRAM | Examples (check [ollama.com/library](https://ollama.com/library) for current versions) |
|---|---|---|
| 3-4B | 2-3GB | Llama 3.2 3B, Phi mini, Gemma small |
| 7-9B | 5-6GB | Llama 3.1 8B, Qwen 7-8B, Mistral 7B, Gemma 9B |
| 12-14B | 8-9GB | Partly spills into system RAM; noticeably slower |

7-9B models are the sweet spot for this card.

## Sizing the VM

The model runs in the GPU's VRAM, so the VM needs much less system RAM than you might expect.

| Resource | Suggested | Why |
|---|---|---|
| RAM | 8GB (12-16GB if running models bigger than VRAM) | Ollama, Open WebUI, and the OS. Model weights live on the GPU |
| CPU | 4 cores, type `host` | Only matters when a model spills out of VRAM |
| Disk | 100GB | Models are 2-6GB each and accumulate |
| Ballooning | Off | With a passed-through GPU, the VM's RAM is pinned and can't be ballooned |

Because passthrough pins the VM's memory, every GB you give it is unavailable to other guests even when idle. Plan: free RAM on `HydraServerMox` by lowering `WIN-DC01` (VM `106`) from 8GB, since it runs nothing but AD. TODO: confirm the host's total RAM and what Unraid, `WIN-DC01`, and Immich (6GB) use after that (`free -h` on the host, plus each guest's memory setting).

## Setup

### 1. Install the card

- **Power:** the 3070 is a ~220W card and NVIDIA recommends a 650W PSU. It needs PCIe power connectors (one or two 8-pin depending on the model). TODO: `HydraServerMox`'s PSU wattage.
- **Slot:** a full-length x16 slot, with room for a 2-slot card plus airflow.
- Boot the host and check the card shows up:
  ```
  lspci -nn | grep -i nvidia
  ```
  Note the PCI address (e.g. `01:00.0`) and both IDs: the GPU and its audio function (e.g. `[10de:2484]` and `[10de:228b]`).

### 2. Prepare the Proxmox host for passthrough

1. **Enable IOMMU in the BIOS** (Intel VT-d or AMD-Vi) and, for Intel CPUs, on the kernel command line. Check how the host boots:
   ```
   proxmox-boot-tool status
   ```
   - **GRUB:** in `/etc/default/grub`, set `GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"`, then run `update-grub`.
   - **systemd-boot:** add `intel_iommu=on iommu=pt` to `/etc/kernel/cmdline`, then run `proxmox-boot-tool refresh`.

   AMD CPUs have IOMMU on by default; `iommu=pt` is still worth adding.
2. **Load the VFIO modules.** Add to `/etc/modules`:
   ```
   vfio
   vfio_iommu_type1
   vfio_pci
   ```
3. **Keep the host's drivers off the card** and hand it to VFIO, using the IDs from step 1:
   ```
   echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
   echo "blacklist nvidia" >> /etc/modprobe.d/blacklist.conf
   echo "options vfio-pci ids=10de:XXXX,10de:YYYY" > /etc/modprobe.d/vfio.conf
   update-initramfs -u -k all
   reboot
   ```
4. **Verify:**
   ```
   dmesg | grep -i -e DMAR -e IOMMU     # IOMMU enabled
   lspci -nnk -s 01:00                  # "Kernel driver in use: vfio-pci" for both functions
   ```

### 3. Create the VM

In the Proxmox UI on `HydraServerMox`:

| Setting | Value |
|---|---|
| ISO | Ubuntu Server 24.04 LTS |
| Machine | `q35` |
| BIOS | OVMF (UEFI). Add an EFI disk and **untick "Pre-Enroll keys"** (turns off Secure Boot, so the NVIDIA driver loads without signing) |
| Disk | 100GB on `NVMe-local` (note: that pool has no redundancy) |
| CPU | 4 cores, type `host` |
| Memory | 8192 MiB, ballooning off |
| Network | `vmbr0` |

Then add the GPU: **Hardware → Add → PCI Device → Raw Device**, pick the 3070, and tick **All Functions** and **PCI-Express** (leave Primary GPU unticked). From the shell, the equivalent is:
```
qm set <VMID> --hostpci0 0000:01:00,pcie=1
```

Install Ubuntu Server as normal (enable OpenSSH during install).

### 4. Install the NVIDIA driver in the VM

```
sudo apt update && sudo apt full-upgrade -y
sudo ubuntu-drivers install
sudo reboot
nvidia-smi        # should show the RTX 3070
```

### 5. Install Ollama

```
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.1:8b
ollama run llama3.1:8b       # chat in the terminal; /bye to exit
ollama ps                    # PROCESSOR column should say 100% GPU
```

Ollama listens only on `127.0.0.1:11434` by default. To let other machines on the LAN use it:
```
sudo systemctl edit ollama
```
add:
```
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
```
then `sudo systemctl restart ollama`.

### 6. Install Open WebUI (optional)

```
sudo apt install -y docker.io
sudo docker run -d -p 3000:8080 \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --name open-webui --restart always \
  ghcr.io/open-webui/open-webui:main
```
Open `http://<vm-ip>:3000` and create the first account (it becomes the admin).

### 7. Finish

- Give the VM a static IP and add it to the [static-address table](../networking/README.md#static--reserved-addresses), the [Services list](../proxmox/README.md#services), and the [Homepage doc](../dashboard/homepage.md).
- Ollama's API has no authentication. Keep it on the LAN; VLAN 20's firewall rules already block guests from reaching it.

## Open items

- TODO: `HydraServerMox` CPU (Intel or AMD), total RAM, PSU wattage, and a free x16 slot.
- TODO: VM ID and IP once created.
