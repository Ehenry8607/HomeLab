# SSH Access

How admin SSH access to lab machines is set up.

## Approach

- Logins use SSH keys, with one key per device.
- Access is granted per device and per LXC, so each device only gets a shortcut for the LXCs it needs.
- LXCs are set up with the `lab-ssh-key` script. It installs the device's key through Proxmox, saves the LXC's host key, adds an `ssh <name>` shortcut, and tests the login. Steps are in the [SSH Script wiki page](https://wiki.hydralab.lan/en/ssh-script).
- VMs aren't covered by the script, so they're set up by hand.
- Proxmox nodes are reached by IP. `*.hydralab.lan` names go to Caddy (`<caddy-ip>`), which only handles web traffic. See [Reverse proxy](../networking/reverse-proxy.md).
