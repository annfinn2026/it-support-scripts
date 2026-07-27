# 🛠 IT Support & Automation Scripts

En samling af praktiske **PowerShell**, **Bash** og **Docker Compose** scripts udviklet til automatiseret fejlfinding, netværksdiagnostik og systemadministration i et Windows/Linux supportmiljø.

---

### 📂 Indhold

#### 🔹 1. PowerShell (`/powershell`)
* **`Network_Diagnostic_Tool.ps1`**: Automatiseret netværksdiagnostik for Windows-endpoints (IP-konfiguration, DNS flush, ping-test til gateway/DNS, port-tjek samt fejlfindingsrapport).
* **`User_Onboarding_Helper.ps1`**: Hjælpescript til tjek af brugerstatus, gruppemedlemskaber og Active Directory / Entra ID rettigheder.

#### 🔹 2. Bash / Linux (`/bash`)
* **`system_health_check.sh`**: Automatiseret sundhedstjek til Linux/Ubuntu servere (RAM, CPU-belastning, diskplads, ZFS pool-status samt aktive Docker-containers).

#### 🔹 3. Docker & Infrastructure (`/docker`)
* **`docker-compose.homelab.yml`**: Eksempel på opstilling af selvhostede tjenester i et hjemmelab (Samba/CIFS fildeling, WireGuard VPN og DNS-kryptering).

---

### 💻 Anvendelse

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
