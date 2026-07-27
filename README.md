# 🛠 IT Support & Automation Scripts

En samling af praktiske **PowerShell**, **Python**, **Bash** og **Docker Compose** scripts udviklet til automatiseret fejlsøgning, netværksdiagnostik, DNS-fejlsøgning, PC-klargøring, log-analyse og systemadministration i et Windows/Linux supportmiljø.

---

### 📂 Indhold

#### 🐍 1. Python (`/python`)
* **`log_analyzer_and_monitor.py`**: Automatiseret Python-script til IT support-drift:
  - **Endpoint Health Monitoring**: Pinger og måler HTTP statuskoder og ms-svartider på eksterne og interne web-tjenester.
  - **Log-Parser & Fejleksport**: Skanner logfiler for kritiske fejl (`ERROR`, `WARNING`, `CRITICAL`), samler statistik og udskriver linjerapporter.

#### 🔹 2. PowerShell (`/powershell`)
* **`DNS_Troubleshooter.ps1`**: Dedikeret DNS-fejlsøger tool ("It's always DNS!"). Test af DNS-serveres svartid, navneopløsning, automatiske DNS/NetBIOS flushes samt test af Port 53 mod DNS-server.
* **`Domain_Entra_Health_Check.ps1`**: Tjek af Hybrid Entra ID (Azure AD) & Active Directory domæne-status, Single Sign-On (SSO) og Primary Refresh Tokens (PRT).
* **`PC_Provisioning_Cleanup.ps1`**: Automatiseret PC-klargøring og oprydningsscript. Renser temp-filer, validerer Windows Update/BITS tjenester og automatiserer installation af standardsoftware via Microsoft Winget (7-Zip, Chrome, Adobe Reader).
* **`Printer_Search_Tool.ps1`**: Søg efter lokale og netværksbaserede printere, tjek Print Spooler status (og automatisk genstart ved fejl), samt test af RAW printport (Port 9100).
* **`Network_Diagnostic_Tool.ps1`**: Automatiseret netværksdiagnostik for Windows-endpoints (IP-konfiguration, DNS flush, ping-test til gateway/DNS, port-tjek samt fejlfindingsrapport).
* **`User_Onboarding_Helper.ps1`**: Hjælpescript til tjek af brugerstatus, miljøvariabler og rettigheder.

#### 🔹 3. Bash / Linux (`/bash`)
* **`system_health_check.sh`**: Automatiseret sundhedstjek til Linux/Ubuntu servere (RAM, CPU-belastning, diskplads, ZFS pool-status samt aktive Docker-containers).

#### 🔹 4. Docker & Infrastructure (`/docker`)
* **`docker-compose.homelab.yml`**: Eksempel på opstilling af selvhostede tjenester i et hjemmelab (Samba/CIFS fildeling, WireGuard VPN og DNS-kryptering).

---

### 💻 Anvendelse

#### Kør Python Log Analyzer & Endpoint Monitor:
```bash
python3 ./python/log_analyzer_and_monitor.py
```

#### Kør DNS-fejlsøgning i PowerShell:
```powershell
.\powershell\DNS_Troubleshooter.ps1
```

#### Kør PC Klargøring og Oprydning (som Admin):
```powershell
.\powershell\PC_Provisioning_Cleanup.ps1
```

#### Kør sundhedstjek på Linux:
```bash
chmod +x ./bash/system_health_check.sh
./bash/system_health_check.sh
```

---

*Udviklet af Hans Annfinn Johannesen (2026)*
