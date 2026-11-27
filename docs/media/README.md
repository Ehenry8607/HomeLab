# Media Stack

## Plex

Plex runs in VM `103` on `nuc-worker` at `<plex-ip>:32400`. See [plex.md](plex.md) for the full service doc.

## Immich

Immich (photo library) runs in LXC `127` on `HydraServerMox` at `https://immich.hydralab.lan`. See [immich.md](immich.md).

## *arr stack

Prowlarr, Sonarr, Radarr, and qBittorrent run on the Unraid media VM at `<unraid-ip>`.

| App | Purpose | Host / port |
|---|---|---|
| Prowlarr | Indexer manager | Unraid VM (Docker), port TODO: (default `9696`) |
| Sonarr | TV | Unraid VM, `8989` |
| Radarr | Movies | Unraid VM, `7878` |
| qBittorrent | Download client, routed through PIA VPN | Unraid VM, `8080` |

### Prowlarr

Prowlarr stores the indexers and syncs them to Sonarr and Radarr, so indexers are managed in one place. It doesn't download anything; Sonarr and Radarr send grabs straight to qBittorrent.

| Item | Value |
|---|---|
| Synced apps | Sonarr, Radarr |
| Sync level | TODO: (**Settings → Apps**; "Full Sync" means searches go through Prowlarr) |
| Indexers | TODO: list names from Prowlarr's **Indexers** page. Logins and API keys stay in the password manager. |

### VPN for qBittorrent

Traffic from qBittorrent goes out over PIA. TODO: document how (WireGuard/OpenVPN in the container, gluetun, etc.) and the kill-switch behavior if the tunnel drops.

### Paths

TODO: download path, media path, and how they're shared between qBittorrent, the *arrs, and Plex (hardlinks need the same filesystem).
