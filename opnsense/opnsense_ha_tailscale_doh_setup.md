# 🛡️ OPNsense, Home Assistant, ESPHome & Tailscale Setup Guide

En komplet teknisk guide til opsætning af **OPNsense DNS-kryptering (DoH / DoT)**, **Tailscale Subnet Router & Exit Node**, **Home Assistant Studio Code Server** samt **ESPHome Noise API Encryption**.

---

## 📋 Systemoversigt

| Enhed / Komponent | IP-adresse | Beskrivelse / Rolle |
| :--- | :--- | :--- |
| **OPNsense Router** | `192.168.1.1` | Hovedgateway, DoH/DoT DNS-resolver, Tailscale Subnet Router & Exit Node |
| **Home Assistant** | `192.168.1.181:8123` | Smart Home Controller, Studio Code Server, Voice Assistant |
| **ESPHome (`esp_6`)** | `192.168.1.x` | ESP32 Dev Board + DHT22 (Temp/Fugtighed) m. Noise API Encryption |
| **M5Stack Atom Echo** | `192.168.1.161` | ESP32 Voice Assist Smart Speaker |

---

## 1. ⚙️ ESPHome Konfiguration (`esp_6`)

Sikr altid, at ESPHome YAML indeholder en 32-byte base64 Noise Encryption Key under `api:`, så advarsler om usikker forbindelse undgås i Home Assistant.

```yaml
substitutions:
  name: "esp-6"
  friendly_name_esp_6: "esp_6"
  loft: hoyma

esphome:
  name: ${name}
  name_add_mac_suffix: false
  friendly_name: ${friendly_name_esp_6}

esp32:
  board: esp32dev
  framework:
    type: esp-idf

packages:
  esphome.bluetooth-proxy: "github://esphome/bluetooth-proxies/esp32-generic/esp32-generic.yaml@main"

api:
  encryption:
    key: "dQJHEv8Zjv8fvPpsimAa9EPoEBjPQrZOZimOgWrw0zE="

ota:
  - platform: esphome

wifi:
  ssid: "unifi"
  password: "LTnm2eu4R10LhPJf"

sensor:
  - platform: dht
    pin: GPIO26
    temperature:
      name: "Temperatur"
      device_class: temperature
      state_class: measurement
    humidity:
      name: "Luftfugtighed"
      device_class: humidity
      state_class: measurement
    model: DHT22
    update_interval: 30s
```

---

## 2. 🔐 DNS-kryptering på OPNsense (DoT & DoH)

### DNSCrypt-Proxy Server Opsætning (`Services > DNSCrypt-Proxy`)

1. **Cloudflare DoH**: `sdns://AgcAAAAAAAAABzEuMS4xLjEAE2Nsb3VkZmxhcmUtZG5zLmNvbQAvZG5zLXF1ZXJ5`
2. **Quad9 DoH**: `sdns://AgcAAAAAAAAACTkuOS45LjkuOAAZZG5zLnF1YWQ5Lm5ldDo0NDMAL2Rucy1xdWVyeQ`
3. **Google DoH**: `sdns://AgcAAAAAAAAADzguOC44LjggOC44LjQuNAAZZG5zLmdvb2dsZS5jb20AL2Rucy1xdWVyeQ`
4. **AdGuard DoH**: `sdns://AgMAAAAAAAAADTk0LjE0MC4xNAAPZG5zLmFkZ3VhcmQuY29tAC9kbnMtcXVlcnk`

### Unbound Query Forwarding
* I **Services** > **Unbound DNS** > **Query Forwarding**, tilføj en regel der videresender alt domænetrafik (`*`) til `127.0.0.1:5353`.

---

## 3. 🚀 Tailscale Mesh VPN på OPNsense

### Aktivering og Automatisk Opstart ved Reboot
Kør følgende kommandoer via SSH på OPNsense for at sikre, at `tailscaled` starter automatisk ved boot:

```bash
sysrc tailscaled_enable="YES"
mkdir -p /var/run/tailscale
service tailscaled onestart
tailscale up --advertise-routes=192.168.1.0/24 --advertise-exit-node
```

### OPNsense Web UI Synkronisering
* Gå til **VPN** > **Tailscale** > **Settings**:
  - `Enabled` = checked `[x]`
  - `Advertise Exit Node` = checked `[x]`
  - `Advertised Routes` = `192.168.1.0/24`

### Fordele:
* **Subnet Router (`192.168.1.0/24`)**: Få direkte adgang til alle interne enheder (`192.168.1.x`) fra mobil 5G uden at installere Tailscale på hver enkelt enhed.
* **Exit Node**: Beskyt trafik på offentlige Wi-Fi netværk ved at route mobiltrafik igennem hjemmets OPNsense router.
* **Ingen konflikter med Firma-VPN**: Da Tailscale kører på routeren, påvirkes arbejdslaptops med Cisco AnyConnect / GlobalProtect overhovedet ikke.

---

## 4. 💾 Borg Backup CLI & Integritetstjek

### Repository Mål & Konfiguration
* **Mål-URI**: `ssh://root@192.168.1.218/storage/backups/PC/t14/backup`
* **Kryptering**: `repokey-blake2` (Gemt i GNOME Keyring / `BORG_PASSPHRASE`)
* **Miljø**: Fedora Silverblue Toolbox Container (`sudo dnf install -y borgbackup`)

### Manuel Backup Kommando
```bash
export BORG_REPO="ssh://root@192.168.1.218/storage/backups/PC/t14/backup"

borg create \
    --stats \
    --progress \
    --compression zstd \
    --exclude-caches \
    --exclude "$HOME/Downloads" \
    --exclude "$HOME/hedgedoc-app/database" \
    --exclude "$HOME/.cache" \
    --exclude "$HOME/.local/share/Trash" \
    --exclude "$HOME/.var/app" \
    ::"t14-{now:%Y-%m-%d_%H:%M:%S}" \
    "$HOME"
```

### Oprydning af Arkiver (Retention Policy)
```bash
borg prune \
    --list \
    --keep-daily=14 \
    --keep-weekly=4 \
    --keep-monthly=12 \
    --keep-yearly=10 \
    ssh://root@192.168.1.218/storage/backups/PC/t14/backup
```

### Integritetstjek (Integrity Check) & Låse-oprydning
* **Hurtigt Integritetstjek** (Indeks & Arkivstruktur):
  ```bash
  borg check --progress ssh://root@192.168.1.218/storage/backups/PC/t14/backup
  ```
* **Dybdegående Data-Integritetstjek** (SHA-256 Bit-rot verifikation af alle datablokke):
  ```bash
  borg check --verify-data --progress ssh://root@192.168.1.218/storage/backups/PC/t14/backup
  ```
* **Fjern Forældet Lås (Break Lock)**:
  ```bash
  borg break-lock ssh://root@192.168.1.218/storage/backups/PC/t14/backup
  ```

