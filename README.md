# 🛠 IT Support & Automation Scripts

En samling af praktiske **PowerShell**, **Bash** og **Docker Compose** scripts udviklet til automatiseret fejlsøgning, netværksdiagnostik, printerhåndtering og systemadministration i et Windows/Linux supportmiljø.

---

### 📂 Indhold

#### 🔹 1. PowerShell (`/powershell`)
* **`Printer_Search_Tool.ps1`**: Søg efter lokale og netværksbaserede printere, tjek Print Spooler status (og automatisk genstart ved fejl), samt test af RAW printport (Port 9100).
* **`Network_Diagnostic_Tool.ps1`**: Automatiseret netværksdiagnostik for Windows-endpoints (IP-konfiguration, DNS flush, ping-test til gateway/DNS, port-tjek samt fejlfindingsrapport).
* **`User_Onboarding_Helper.ps1`**: Hjælpescript til tjek af brugerstatus, miljøvariabler og rettigheder.

#### 🔹 2. Bash / Linux (`/bash`)
* **`system_health_check.sh`**: Automatiseret sundhedstjek til Linux/Ubuntu servere (RAM, CPU-belastning, diskplads, ZFS pool-status samt aktive Docker-containers).

#### 🔹 3. Docker & Infrastructure (`/docker`)
* **`docker-compose.homelab.yml`**: Eksempel på opstilling af selvhostede tjenester i et hjemmelab (Samba/CIFS fildeling, WireGuard VPN og DNS-kryptering).

---

### 💻 Anvendelse

#### Søg efter printere eller IP-adresse:
```powershell
.\powershell\Printer_Search_Tool.ps1 -SearchPattern "HP"
.\powershell\Printer_Search_Tool.ps1 -SearchPattern "192.168.1.150"
```

#### Kør netværkstest i PowerShell:
```powershell
.\powershell\Network_Diagnostic_Tool.ps1
```

#### Kør sundhedstjek på Linux:
```bash
chmod +x ./bash/system_health_check.sh
./bash/system_health_check.sh
```

---

*Udviklet af Hans Annfinn Johannesen (2026)*
